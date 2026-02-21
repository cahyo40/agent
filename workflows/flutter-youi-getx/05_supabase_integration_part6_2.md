---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Sub-part 2/3)
---
            const SizedBox(height: 16),

            // Upload progress
            Obx(() {
              if (controller.isUploading.value) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: controller.uploadProgress.value,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(controller.uploadProgress.value * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 16),

            // Upload button
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isUploading.value
                        ? null
                        : () => controller.uploadFile(
                              bucket: 'products',
                              folder: 'images',
                            ),
                    child: controller.isUploading.value
                        ? const Text('Uploading...')
                        : const Text('Upload'),
                  ),
                )),

            const SizedBox(height: 24),

            // Uploaded files list
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: controller.uploadedFiles.length,
                    itemBuilder: (context, index) {
                      final url = controller.uploadedFiles[index];
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
                          onPressed: () => controller.deleteFile(
                            bucket: 'products',
                            path: url.split('/storage/v1/object/public/products/').last,
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// UPLOAD BINDING
// ============================================================

// features/upload/bindings/upload_binding.dart
import 'package:get/get.dart';
import '../presentation/controllers/upload_controller.dart';

class UploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadController>(() => UploadController());
  }
}

// ============================================================
// SQL: Storage RLS Policies — Sama dengan versi Riverpod
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

