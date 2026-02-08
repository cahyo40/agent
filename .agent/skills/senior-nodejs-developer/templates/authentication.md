# Authentication Patterns

## JWT Authentication

```typescript
// src/lib/jwt.ts
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { UnauthorizedError } from '../errors';

interface TokenPayload {
  userId: string;
  email: string;
  role: string;
}

interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

export function generateTokens(payload: TokenPayload): TokenPair {
  const accessToken = jwt.sign(payload, config.jwt.accessSecret, {
    expiresIn: config.jwt.accessExpiry, // e.g., '15m'
  });

  const refreshToken = jwt.sign(
    { userId: payload.userId },
    config.jwt.refreshSecret,
    { expiresIn: config.jwt.refreshExpiry } // e.g., '7d'
  );

  return { accessToken, refreshToken };
}

export function verifyAccessToken(token: string): TokenPayload {
  try {
    return jwt.verify(token, config.jwt.accessSecret) as TokenPayload;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new UnauthorizedError('Token expired');
    }
    throw new UnauthorizedError('Invalid token');
  }
}

export function verifyRefreshToken(token: string): { userId: string } {
  try {
    return jwt.verify(token, config.jwt.refreshSecret) as { userId: string };
  } catch {
    throw new UnauthorizedError('Invalid refresh token');
  }
}
```

## Auth Middleware

```typescript
// src/middleware/authenticate.ts
import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../lib/jwt';
import { UnauthorizedError } from '../errors';

export interface AuthenticatedRequest extends Request {
  user: {
    userId: string;
    email: string;
    role: string;
  };
}

export function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction
): void {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    throw new UnauthorizedError('No token provided');
  }

  const token = authHeader.substring(7);
  const payload = verifyAccessToken(token);

  (req as AuthenticatedRequest).user = payload;
  next();
}

// Optional auth (doesn't throw if no token)
export function optionalAuth(
  req: Request,
  _res: Response,
  next: NextFunction
): void {
  const authHeader = req.headers.authorization;

  if (authHeader?.startsWith('Bearer ')) {
    try {
      const token = authHeader.substring(7);
      const payload = verifyAccessToken(token);
      (req as AuthenticatedRequest).user = payload;
    } catch {
      // Ignore invalid tokens for optional auth
    }
  }

  next();
}
```

## Role-Based Authorization

```typescript
// src/middleware/authorize.ts
import { Request, Response, NextFunction } from 'express';
import { AuthenticatedRequest } from './authenticate';
import { ForbiddenError } from '../errors';

export function authorize(...allowedRoles: string[]) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const { user } = req as AuthenticatedRequest;

    if (!user) {
      throw new ForbiddenError('Not authenticated');
    }

    if (!allowedRoles.includes(user.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }

    next();
  };
}

// Usage
router.delete('/users/:id', authenticate, authorize('admin'), deleteUser);
router.get('/admin/stats', authenticate, authorize('admin', 'moderator'), getStats);
```

## Auth Controller

```typescript
// src/controllers/auth.controller.ts
import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';
import { LoginDto, RegisterDto, RefreshDto } from '../schemas/auth.schema';
import { HttpStatus } from '../types';

export class AuthController {
  constructor(private authService: AuthService) {}

  register = async (req: Request, res: Response): Promise<void> => {
    const dto = req.body as RegisterDto;
    const result = await this.authService.register(dto);
    res.status(HttpStatus.CREATED).json(result);
  };

  login = async (req: Request, res: Response): Promise<void> => {
    const dto = req.body as LoginDto;
    const result = await this.authService.login(dto);

    // Set refresh token as HTTP-only cookie
    res.cookie('refreshToken', result.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    res.json({
      accessToken: result.accessToken,
      user: result.user,
    });
  };

  refresh = async (req: Request, res: Response): Promise<void> => {
    const refreshToken = req.cookies.refreshToken || req.body.refreshToken;

    if (!refreshToken) {
      res.status(401).json({ message: 'Refresh token required' });
      return;
    }

    const result = await this.authService.refresh(refreshToken);

    res.cookie('refreshToken', result.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 7 * 24 * 60 * 60 * 1000,
    });

    res.json({ accessToken: result.accessToken });
  };

  logout = async (req: Request, res: Response): Promise<void> => {
    const refreshToken = req.cookies.refreshToken;

    if (refreshToken) {
      await this.authService.revokeToken(refreshToken);
    }

    res.clearCookie('refreshToken');
    res.status(HttpStatus.NO_CONTENT).send();
  };
}
```

## Auth Service

```typescript
// src/services/auth.service.ts
import { prisma } from '../lib/prisma';
import { generateTokens, verifyRefreshToken } from '../lib/jwt';
import { redis } from '../lib/redis';
import { hashPassword, verifyPassword } from '../utils/crypto';
import { UnauthorizedError, ConflictError } from '../errors';
import { RegisterDto, LoginDto } from '../schemas/auth.schema';

export class AuthService {
  async register(dto: RegisterDto) {
    const exists = await prisma.user.findUnique({ where: { email: dto.email } });
    if (exists) {
      throw new ConflictError('Email already registered');
    }

    const user = await prisma.user.create({
      data: {
        email: dto.email,
        name: dto.name,
        password: await hashPassword(dto.password),
      },
      select: { id: true, email: true, name: true, role: true },
    });

    const tokens = generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    // Store refresh token hash
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return { ...tokens, user };
  }

  async login(dto: LoginDto) {
    const user = await prisma.user.findUnique({
      where: { email: dto.email },
      select: { id: true, email: true, name: true, role: true, password: true },
    });

    if (!user || !(await verifyPassword(dto.password, user.password))) {
      throw new UnauthorizedError('Invalid credentials');
    }

    const tokens = generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    await this.storeRefreshToken(user.id, tokens.refreshToken);

    const { password: _, ...userWithoutPassword } = user;
    return { ...tokens, user: userWithoutPassword };
  }

  async refresh(refreshToken: string) {
    const payload = verifyRefreshToken(refreshToken);

    // Check if token is valid (not revoked)
    const isValid = await this.isTokenValid(payload.userId, refreshToken);
    if (!isValid) {
      throw new UnauthorizedError('Refresh token revoked');
    }

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: { id: true, email: true, role: true },
    });

    if (!user) {
      throw new UnauthorizedError('User not found');
    }

    // Rotate refresh token
    await this.revokeToken(refreshToken);

    const tokens = generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return tokens;
  }

  async revokeToken(token: string): Promise<void> {
    const hash = this.hashToken(token);
    await redis.del(`refresh:${hash}`);
  }

  private async storeRefreshToken(userId: string, token: string): Promise<void> {
    const hash = this.hashToken(token);
    await redis.setex(`refresh:${hash}`, 7 * 24 * 60 * 60, userId);
  }

  private async isTokenValid(userId: string, token: string): Promise<boolean> {
    const hash = this.hashToken(token);
    const storedUserId = await redis.get(`refresh:${hash}`);
    return storedUserId === userId;
  }

  private hashToken(token: string): string {
    return require('crypto').createHash('sha256').update(token).digest('hex');
  }
}
```

## OAuth2 with Passport

```typescript
// src/config/passport.ts
import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';
import { Strategy as GitHubStrategy } from 'passport-github2';
import { prisma } from '../lib/prisma';
import { config } from '../config';

passport.use(
  new GoogleStrategy(
    {
      clientID: config.oauth.google.clientId,
      clientSecret: config.oauth.google.clientSecret,
      callbackURL: '/api/v1/auth/google/callback',
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        let user = await prisma.user.findUnique({
          where: { googleId: profile.id },
        });

        if (!user) {
          user = await prisma.user.create({
            data: {
              googleId: profile.id,
              email: profile.emails?.[0]?.value ?? '',
              name: profile.displayName,
              avatar: profile.photos?.[0]?.value,
            },
          });
        }

        done(null, user);
      } catch (error) {
        done(error as Error);
      }
    }
  )
);

// Routes
router.get('/google', passport.authenticate('google', { scope: ['profile', 'email'] }));

router.get(
  '/google/callback',
  passport.authenticate('google', { session: false }),
  async (req, res) => {
    const user = req.user as User;
    const tokens = generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    // Redirect to frontend with token
    res.redirect(`${config.frontendUrl}/auth/callback?token=${tokens.accessToken}`);
  }
);
```

## Password Utils

```typescript
// src/utils/crypto.ts
import { scrypt, randomBytes, timingSafeEqual } from 'crypto';
import { promisify } from 'util';

const scryptAsync = promisify(scrypt);

export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16).toString('hex');
  const derivedKey = (await scryptAsync(password, salt, 64)) as Buffer;
  return `${salt}:${derivedKey.toString('hex')}`;
}

export async function verifyPassword(
  password: string,
  hash: string
): Promise<boolean> {
  const [salt, key] = hash.split(':');
  const derivedKey = (await scryptAsync(password, salt, 64)) as Buffer;
  const keyBuffer = Buffer.from(key, 'hex');
  return timingSafeEqual(derivedKey, keyBuffer);
}

// Alternative: bcrypt
import bcrypt from 'bcryptjs';

export async function hashPasswordBcrypt(password: string): Promise<string> {
  return bcrypt.hash(password, 12);
}

export async function verifyPasswordBcrypt(
  password: string,
  hash: string
): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```
