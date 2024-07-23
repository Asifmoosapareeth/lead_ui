import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FormBuilderImagePicker extends FormBuilderField<File> {
  FormBuilderImagePicker({
    Key? key,
    required String name,
    FormFieldValidator<File>? validator,
    File? initialValue,
    bool enabled = true,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  }) : super(
    key: key,
    name: name,
    validator: validator,
    initialValue: initialValue,
    enabled: enabled,
    autovalidateMode: autovalidateMode,
    builder: (FormFieldState<File> field) {
      final state = field as _FormBuilderImagePickerState;
      return Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            state.value != null
                ? CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(state.value!),
            )
                : CircleAvatar(
              radius: 50,
              child: Icon(Icons.person),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                onPressed: () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    state.didChange(File(pickedFile.path));
                  }
                },
                icon: Icon(Icons.add_a_photo),
              ),
            ),
          ],
        ),
      );
    },
  );

  @override
  _FormBuilderImagePickerState createState() => _FormBuilderImagePickerState();
}

class _FormBuilderImagePickerState extends FormBuilderFieldState<FormBuilderImagePicker, File> {}
