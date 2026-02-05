---
name: senior-nestjs-developer
description: "Expert NestJS development including modular architecture, TypeORM/Prisma, authentication, microservices, and production-ready TypeScript APIs"
---

# Senior NestJS Developer

## Overview

This skill transforms you into an expert NestJS developer who builds enterprise-grade, scalable backend applications with clean architecture, advanced dependency injection, and production-ready APIs.

## When to Use This Skill

- Building REST or GraphQL APIs with NestJS
- Implementing microservices architecture
- Setting up authentication (JWT, OAuth, Passport)
- Integrating databases with TypeORM or Prisma

## Project Architecture

```text
src/
├── app.module.ts              # Root module
├── main.ts                    # Entry point
├── common/
│   ├── decorators/            # Custom decorators
│   ├── filters/               # Exception filters
│   ├── guards/                # Auth guards
│   └── interceptors/          # Response interceptors
├── modules/
│   ├── auth/                  # Authentication module
│   └── users/                 # Users module
└── database/
    └── migrations/
```

## Core Patterns

### Module Setup

```typescript
// app.module.ts
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST'),
        database: config.get('DB_DATABASE'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: config.get('NODE_ENV') === 'development',
      }),
    }),
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 100 }]),
    AuthModule,
    UsersModule,
  ],
})
export class AppModule {}
```

### Entity Pattern

```typescript
// entities/user.entity.ts
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  @Exclude()
  password: string;

  @CreateDateColumn()
  createdAt: Date;

  @BeforeInsert()
  async hashPassword() {
    this.password = await bcrypt.hash(this.password, 10);
  }
}
```

### Service Pattern

```typescript
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async findOne(id: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) throw new NotFoundException(`User ${id} not found`);
    return user;
  }

  async create(dto: CreateUserDto): Promise<User> {
    const user = this.usersRepository.create(dto);
    return this.usersRepository.save(user);
  }
}
```

### DTO Validation

```typescript
export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsString()
  name: string;
}

export class UpdateUserDto extends PartialType(CreateUserDto) {}
```

### JWT Authentication

```typescript
// jwt.strategy.ts
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: configService.get('JWT_SECRET'),
    });
  }

  async validate(payload: JwtPayload): Promise<User> {
    return { id: payload.sub, email: payload.email, role: payload.role };
  }
}

// guards/roles.guard.ts
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const roles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!roles) return true;
    const { user } = context.switchToHttp().getRequest();
    return roles.includes(user.role);
  }
}
```

### Controller Pattern

```typescript
@ApiTags('Users')
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  async findAll(@Query() query: PaginationDto) {
    return this.usersService.findAll(query);
  }

  @Post()
  @Roles('admin')
  async create(@Body() dto: CreateUserDto) {
    return this.usersService.create(dto);
  }

  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.findOne(id);
  }
}
```

### Exception Filter

```typescript
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    response.status(status).json({
      success: false,
      statusCode: status,
      message: exception instanceof HttpException
        ? exception.message
        : 'Internal server error',
    });
  }
}
```

## Best Practices

### ✅ Do This

- Use modules to organize features
- Implement proper validation with class-validator
- Use DTOs to define API contracts
- Implement global exception filters
- Document APIs with Swagger/OpenAPI
- Write unit and e2e tests

### ❌ Avoid

- Don't put business logic in controllers
- Don't skip input validation
- Don't expose internal errors to clients
- Don't hardcode configuration values

## Related Skills

- `@senior-typescript-developer` - TypeScript patterns
- `@senior-nodejs-developer` - Node.js fundamentals
- `@senior-graphql-developer` - GraphQL with NestJS
