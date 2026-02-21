---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 2/3)
---
               // Upload progress bar - reactive
               Obx(() {
                 if (!controller.isUploading.value) {
                   return const SizedBox.shrink();
                 }
                 return Column(
                   children: [
                     LinearProgressIndicator(
                       value: controller.uploadProgress.value,
                     ),
                     const SizedBox(height: 8),
                     Text(
                       '${(controller.uploadProgress.value * 100).toStringAsFixed(1)}%',
                       style: Theme.of(context).textTheme.bodySmall,
                     ),
                   ],
                 );
               }),
               const SizedBox(height: 16),

               // Upload button
               Obx(() => SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: controller.isUploading.value
                           ? null
                           : controller.uploadProfileImage,
                       child: controller.isUploading.value
                           ? const Text('Uploading...')
                           : const Text('Upload'),
                     ),
                   )),

               // Error message
               Obx(() {
                 if (controller.errorMessage.isEmpty) {
                   return const SizedBox.shrink();
                 }
                 return Padding(
                   padding: const EdgeInsets.only(top: 8),
                   child: Text(
                     controller.errorMessage.value,
                     style: const TextStyle(color: Colors.red),
                   ),
                 );
               }),
             ],
           ),
         ),
       );
     }
   }
   ```

4. **Storage Security Rules:**
   ```
   // storage.rules
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       // Profile images - hanya owner yang bisa write
       match /profile_images/{userId}/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null
           && request.auth.uid == userId
           && request.resource.size < 5 * 1024 * 1024  // Max 5MB
           && request.resource.contentType.matches('image/.*');
       }

       // Product images
       match /product_images/{productId}/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null
           && request.resource.size < 10 * 1024 * 1024  // Max 10MB
           && request.resource.contentType.matches('image/.*');
       }

       // Documents
       match /documents/{userId}/{allPaths=**} {
         allow read: if request.auth != null && request.auth.uid == userId;
         allow write: if request.auth != null
           && request.auth.uid == userId
           && request.resource.size < 20 * 1024 * 1024;  // Max 20MB
       }
     }
   }
   ```

