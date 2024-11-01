/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/settings/settings_common_cubit.dart';
import '../cubit/settings/settings_common_item_cubit.dart';
import '../cubit/settings/settings_common_item_state.dart';
import '../models/settings_item.dart';
import 'fields_common.dart';

mixin SettingsCommon on FieldsCommon {
  InputDecoration textFieldDecoration(
    String hint,
    String label,
    IconData iconData, {
    String? errorText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      isDense: true,
      prefixIcon: Icon(iconData),
      errorText: errorText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.elliptical(8, 8),
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }

  InputDecoration passwordFieldDecoration(
    String hint,
    String label,
    IconData iconData,
    bool visibility,
    void Function() visibilityPressed, {
    String? errorText,
  }) {
    return textFieldDecoration(
      hint,
      label,
      iconData,
      errorText: errorText,
      suffixIcon: IconButton(
        onPressed: () {
          visibilityPressed();
        },
        icon: Icon(
          visibility ? Icons.visibility : Icons.visibility_off,
        ),
      ),
    );
  }

  Widget
      checkboxGroup<Cs extends SettingsCommonCubit<T>, T extends SettingsItem>(
    String title,
    List<String> values,
    void Function(bool, String) updateHandler,
  ) {
    return BlocBuilder<Cs, SettingsCommonState>(
      builder: (context, state) {
        List<Widget> children = [];
        for (SettingsItem item
            in (state is SettingsCommonUpdatedState<T> ? state.items : <T>[])) {
          children.add(
            CheckboxListTile(
              title: Text(item.name),
              value: values.contains(item.name),
              onChanged: (value) {
                updateHandler(value!, item.name);
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Text(
                  '$title:',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                border: Border.all(width: 1.0),
              ),
              padding: EdgeInsets.all(4.0),
              child: Column(
                children: children,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget autoDropDownMenu<Cs extends SettingsCommonCubit<T>,
      T extends SettingsItem>(
    String title,
    String value,
    void Function(String?) updateHandler,
  ) {
    return BlocBuilder<Cs, SettingsCommonState>(
      builder: (context, state) {
        List<String> items = state is SettingsCommonUpdatedState<T>
            ? state.items.map((item) => item.name).toList()
            : [];

        if (value.isEmpty && items.isNotEmpty) {
          updateHandler(items[0]);
        }

        return dropDownMenu<String>(
          title,
          items,
          value.isNotEmpty && items.contains(value)
              ? value
              : items.isNotEmpty
                  ? items[0]
                  : '',
          (item) => item,
          (item) {
            updateHandler(item!);
          },
        );
      },
    );
  }

  Widget builder<
      Cs extends SettingsCommonCubit<T>,
      C extends SettingsCommonItemCubit<S, T>,
      S extends SettingsCommonItemState,
      T extends SettingsItem>(
    String title,
    BuildContext context,
    GlobalKey<FormState> formKey,
    T item,
    C cubit,
    Widget Function(GlobalKey<FormState>, BuildContext) form,
    List<Widget> Function(T) getSubTitle,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: BlocProvider(
        create: (context) => cubit,
        child: Column(
          children: [
            form(formKey, context),
            verticalSpacing(),
            BlocBuilder<C, S>(
              builder: (context, state) {
                return submitButton<Cs, C, S, T>(
                  title,
                  context,
                  formKey,
                  state.index,
                  item,
                );
              },
            ),
            verticalSpacing(),
            BlocBuilder<C, S>(
              builder: (context, state) {
                return cancelButton(
                  context.read<C>().reset,
                );
              },
            ),
            createView<Cs, C, T>(
              title,
              (state) => state.items,
              (item) => item.name,
              getSubTitle,
              (cubit) => cubit.editData,
              (cubit) => cubit.removeLocation,
            )
          ],
        ),
      ),
    );
  }

  Widget submitButton<
      Cs extends SettingsCommonCubit<T>,
      C extends SettingsCommonItemCubit<S, T>,
      S extends SettingsCommonItemState,
      T extends SettingsItem>(
    String title,
    BuildContext context,
    GlobalKey<FormState> formKey,
    int index,
    T value,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48.0,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            context.read<C>().saveStateDefaults();
            if (index < 0) {
              context.read<Cs>().addItem(value);
            } else {
              context.read<Cs>().editItem(index, value);
            }
            context.read<C>().reset();
          } else {
            context.read<C>().updateAutovalidateMode(AutovalidateMode.always);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save),
            horizontalSpacing(),
            Text(
              index < 0 ? 'Add $title' : 'Update $title',
            ),
          ],
        ),
      ),
    );
  }

  Widget cancelButton(
    void Function() reset,
  ) {
    return ElevatedButton(
      onPressed: () {
        reset();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.clear),
          horizontalSpacing(),
          Text('Cancel'),
        ],
      ),
    );
  }

  Widget createView<ViewCubit extends Cubit<SettingsCommonState>, ItemCubit,
      T extends SettingsItem>(
    String title,
    List<T> Function(SettingsCommonUpdatedState<T>) getItems,
    String Function(T) getTileTitle,
    List<Widget> Function(T) getTileSubTitle,
    void Function(int, T) Function(ItemCubit) editItem,
    void Function(int) Function(ViewCubit) removeItem,
  ) {
    return BlocBuilder<ViewCubit, SettingsCommonState>(
      builder: (context, state) {
        if (state is SettingsCommonInitialState) {
          return buildEmptyViewList(title);
        }

        if (state is SettingsCommonUpdatedState<T>) {
          return buildViewList(
            getItems(state),
            getTileTitle,
            getTileSubTitle,
            editItem(context.read<ItemCubit>()),
            removeItem(context.read<ViewCubit>()),
          );
        }

        return Container();
      },
    );
  }

  Widget buildEmptyViewList(String name) {
    return Center(
      child: Text('Please add a $name'),
    );
  }

  Widget buildViewList<T>(
    List<T> items,
    String Function(T) getTitle,
    List<Widget> Function(T) getSubTitle,
    void Function(int, T) editItem,
    void Function(int) removeItem,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        T item = items[index];
        return ListTile(
          title: Text(
            getTitle(item),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          subtitle: Row(
            children: getSubTitle(item),
          ),
          trailing: IconButton(
            onPressed: () {
              editItem(index, item);
            },
            icon: Icon(
              Icons.edit,
              color: Colors.blue,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              removeItem(index);
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }
}
