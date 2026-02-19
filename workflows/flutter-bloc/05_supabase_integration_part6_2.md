---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Sub-part 2/3)
---
class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UploadCubit>(),
      child: const _UploadView(),
    );
  }
}

class _UploadView extends StatelessWidget {
  const _UploadView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: BlocListener<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state.status == UploadStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Upload gagal')),
            );
          }
          if (state.status == UploadStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload berhasil!')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Preview selected file
              BlocBuilder<UploadCubit, UploadState>(
                buildWhen: (prev, curr) =>
                    prev.selectedFile != curr.selectedFile,
                builder: (context, state) {
                  if (state.selectedFile != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        state.selectedFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  return Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Belum ada file dipilih'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Pick buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.read<UploadCubit>().pickImage(),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.read<UploadCubit>().takePhoto(),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Upload progress
              BlocBuilder<UploadCubit, UploadState>(
                buildWhen: (prev, curr) =>
                    prev.progress != curr.progress ||
                    prev.status != curr.status,
                builder: (context, state) {
                  if (state.status == UploadStatus.uploading) {
                    return Column(
                      children: [
                        LinearProgressIndicator(value: state.progress),
                        const SizedBox(height: 8),
                        Text(
                          '${(state.progress * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 16),

              // Upload button
              BlocBuilder<UploadCubit, UploadState>(
                builder: (context, state) {
                  final isUploading = state.status == UploadStatus.uploading;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () => context.read<UploadCubit>().uploadImage(
                                bucket: 'products',
                                folder: 'images',
                              ),
                      child: isUploading
                          ? const Text('Uploading...')
                          : const Text('Upload'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Uploaded files list
              Expanded(
                child: BlocBuilder<UploadCubit, UploadState>(
                  buildWhen: (prev, curr) =>
                      prev.uploadedFiles != curr.uploadedFiles,
                  builder: (context, state) {
                    return ListView.builder(
                      itemCount: state.uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final url = state.uploadedFiles[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            url.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                context.read<UploadCubit>().deleteFile(
                                      bucket: 'products',
                                      path: url
                                          .split(
                                              '/storage/v1/object/public/products/')
                                          .last,
                                    ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SQL: Storage RLS Policies — Framework-agnostic
// ============================================================
/*
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'products' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to update their own files
CREATE POLICY "Users can update their own files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'products' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to delete their own files
CREATE POLICY "Users can delete their own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'products' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow anyone to read public bucket files
CREATE POLICY "Anyone can view public files"
ON storage.objects FOR SELECT
TO anon
USING (bucket_id = 'products');

-- Allow authenticated users to read all files
CREATE POLICY "Authenticated can view all files"
ON storage.objects FOR SELECT
TO authenticated
USING (true);
*/
```

