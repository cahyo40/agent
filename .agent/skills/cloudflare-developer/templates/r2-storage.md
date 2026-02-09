# R2 Object Storage

## Basic Operations

```typescript
import { Hono } from 'hono'

type Bindings = {
  BUCKET: R2Bucket
}

const app = new Hono<{ Bindings: Bindings }>()

// Upload file
app.post('/upload', async (c) => {
  const formData = await c.req.formData()
  const file = formData.get('file') as File
  
  if (!file) {
    return c.json({ error: 'No file provided' }, 400)
  }
  
  const key = `uploads/${Date.now()}-${file.name}`
  const arrayBuffer = await file.arrayBuffer()
  
  await c.env.BUCKET.put(key, arrayBuffer, {
    httpMetadata: {
      contentType: file.type,
    },
    customMetadata: {
      originalName: file.name,
      uploadedAt: new Date().toISOString(),
    },
  })
  
  return c.json({ 
    key,
    url: `/files/${key}`,
    size: file.size 
  })
})

// Download file
app.get('/files/*', async (c) => {
  const key = c.req.path.replace('/files/', '')
  const object = await c.env.BUCKET.get(key)
  
  if (!object) {
    return c.json({ error: 'File not found' }, 404)
  }
  
  const headers = new Headers()
  object.writeHttpMetadata(headers)
  headers.set('etag', object.httpEtag)
  
  return new Response(object.body, { headers })
})

// Delete file
app.delete('/files/*', async (c) => {
  const key = c.req.path.replace('/files/', '')
  await c.env.BUCKET.delete(key)
  return c.json({ success: true })
})

// List files
app.get('/files', async (c) => {
  const prefix = c.req.query('prefix') || ''
  const limit = parseInt(c.req.query('limit') || '100')
  const cursor = c.req.query('cursor')
  
  const listed = await c.env.BUCKET.list({
    prefix,
    limit,
    cursor: cursor || undefined,
  })
  
  return c.json({
    objects: listed.objects.map(obj => ({
      key: obj.key,
      size: obj.size,
      uploaded: obj.uploaded,
      etag: obj.etag,
    })),
    truncated: listed.truncated,
    cursor: listed.cursor,
  })
})

export default app
```

## Image Processing

```typescript
// Upload with image processing
app.post('/images', async (c) => {
  const formData = await c.req.formData()
  const file = formData.get('image') as File
  
  if (!file) {
    return c.json({ error: 'No image provided' }, 400)
  }
  
  // Validate image type
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif']
  if (!allowedTypes.includes(file.type)) {
    return c.json({ error: 'Invalid image type' }, 400)
  }
  
  // Max size 10MB
  if (file.size > 10 * 1024 * 1024) {
    return c.json({ error: 'File too large (max 10MB)' }, 400)
  }
  
  const id = crypto.randomUUID()
  const ext = file.name.split('.').pop()
  const key = `images/${id}.${ext}`
  
  await c.env.BUCKET.put(key, await file.arrayBuffer(), {
    httpMetadata: {
      contentType: file.type,
      cacheControl: 'public, max-age=31536000',
    },
    customMetadata: {
      originalName: file.name,
      width: '', // Set after processing if using Workers AI
      height: '',
    },
  })
  
  return c.json({
    id,
    key,
    url: `/images/${key}`,
    type: file.type,
    size: file.size,
  })
})
```

## Presigned URLs (Using Signed URLs Pattern)

```typescript
import { SignJWT, jwtVerify } from 'jose'

async function generateSignedUrl(
  key: string, 
  secret: string, 
  expiresInSeconds = 3600
): Promise<string> {
  const token = await new SignJWT({ key })
    .setProtectedHeader({ alg: 'HS256' })
    .setExpirationTime(`${expiresInSeconds}s`)
    .sign(new TextEncoder().encode(secret))
  
  return `/signed/${token}`
}

app.get('/signed/:token', async (c) => {
  const token = c.req.param('token')
  
  try {
    const { payload } = await jwtVerify(
      token,
      new TextEncoder().encode(c.env.SIGNING_SECRET)
    )
    
    const object = await c.env.BUCKET.get(payload.key as string)
    if (!object) {
      return c.json({ error: 'File not found' }, 404)
    }
    
    const headers = new Headers()
    object.writeHttpMetadata(headers)
    return new Response(object.body, { headers })
  } catch {
    return c.json({ error: 'Invalid or expired token' }, 401)
  }
})
```

## Multipart Upload (Large Files)

```typescript
// For files > 5MB, use multipart upload
async function uploadLargeFile(
  bucket: R2Bucket,
  key: string,
  data: ReadableStream,
  size: number
): Promise<R2Object> {
  const PART_SIZE = 10 * 1024 * 1024 // 10MB parts
  
  if (size < PART_SIZE) {
    // Small file, direct upload
    return await bucket.put(key, data)
  }
  
  // Large file, multipart upload
  const upload = await bucket.createMultipartUpload(key)
  const parts: R2UploadedPart[] = []
  
  const reader = data.getReader()
  let partNumber = 1
  let buffer = new Uint8Array(0)
  
  while (true) {
    const { done, value } = await reader.read()
    
    if (value) {
      const newBuffer = new Uint8Array(buffer.length + value.length)
      newBuffer.set(buffer)
      newBuffer.set(value, buffer.length)
      buffer = newBuffer
    }
    
    if (buffer.length >= PART_SIZE || (done && buffer.length > 0)) {
      const part = await upload.uploadPart(partNumber, buffer.slice(0, PART_SIZE))
      parts.push(part)
      buffer = buffer.slice(PART_SIZE)
      partNumber++
    }
    
    if (done) break
  }
  
  return await upload.complete(parts)
}
```
