# YoUI Form Components

## YoForm

```dart
YoForm(
  onSubmit: (values) => submit(values),
  children: [
    YoForm.text(
      name: 'email',
      label: 'Email',
      validator: (v) => v?.isEmpty == true ? 'Required' : null,
    ),
    YoForm.password(
      name: 'password',
      label: 'Password',
    ),
    YoButton.primary(text: 'Submit', onPressed: null), // auto-submit
  ],
)
```

## YoSearchField

```dart
YoSearchField(
  hintText: 'Search products...',
  suggestions: ['Item 1', 'Item 2', 'Item 3'],
  onSearch: (query) => search(query),
  onChanged: (text) => filterLocal(text),
  debounceMs: 300,
)
```

## YoOtpField

```dart
YoOtpField(
  length: 6,
  onCompleted: (pin) => verifyOtp(pin),
  onChanged: (value) {},
  obscureText: false,
)
```

## YoDropdown

```dart
YoDropdown<String>(
  label: 'Select Category',
  items: categories.map((c) => YoDropdownItem(
    value: c.id,
    label: c.name,
  )).toList(),
  onChanged: (value) => selectCategory(value),
)
```

## YoChipInput

```dart
YoChipInput(
  chips: ['Tag1', 'Tag2'],
  suggestions: ['Tag3', 'Tag4', 'Tag5'],
  maxChips: 5,
  onChanged: (chips) => updateTags(chips),
)
```

## YoRangeSlider

```dart
YoRangeSlider(
  values: RangeValues(20, 80),
  min: 0,
  max: 100,
  divisions: 10,
  labels: RangeLabels('\$20', '\$80'),
  onChanged: (values) => filterByPrice(values),
)
```

## YoFileUpload

```dart
YoFileUpload(
  maxFiles: 5,
  allowedExtensions: ['jpg', 'png', 'pdf'],
  maxFileSize: 5 * 1024 * 1024, // 5MB
  onFilesSelected: (files) => uploadFiles(files),
)
```
