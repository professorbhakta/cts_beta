import 'package:cts/appManager/colors.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class SearchableDropDown extends StatefulWidget {
  const SearchableDropDown({
    super.key,
    this.padding,
    this.margin,
    this.width,
    this.dFocus,
    required this.title,
    required this.listData,
    required this.selectedValue,
    required this.onchange,
  });

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final FocusNode? dFocus;
  final String selectedValue;
  final String title;
  final List<String> listData;
  final void Function(String?)? onchange;

  @override
  State<SearchableDropDown> createState() => SearchableDropDownState();
}

class SearchableDropDownState extends State<SearchableDropDown> {
  bool isListOpen = false;
  String searchQuery = '';
  late List<String> _effectiveListData;

  @override
  void initState() {
    super.initState();
    _effectiveListData =
        widget.listData.isEmpty ? ["Select", "No Data Found"] : widget.listData;
  }

  List<String> get filteredList {
    return _effectiveListData.where((item) {
      final String itemName = item.toLowerCase();
      return itemName.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      width: widget.width,
      decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.acYellowWarm,
          ),
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5)),
      child: Focus(
        focusNode: widget.dFocus,
        child: DropdownSearch<String>(
          asyncItems: (searchQuery) => getData(searchQuery),
          selectedItem: widget.selectedValue,
          onChanged: widget.onchange,
          dropdownButtonProps: DropdownButtonProps(
            color: AppColors.acYellowWarm,
          ),
          popupProps: PopupPropsMultiSelection.modalBottomSheet(
            isFilterOnline: true,
            title: Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: AppColors.acYellowWarm,
                width: 04,
              ))),
              child: Center(
                child: Text(
                  widget.title,
                  softWrap: true,
                  style: TextStyle(
                      color: AppColors.acBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ),
            ),
            showSelectedItems: true,
            showSearchBox: true,
            itemBuilder: _customPopupItemBuilderExample2,
          ),
        ),
      ),
    );
  }

  Future<List<String>> getData(String filter) async {
    if (filter.isEmpty) {
      return _effectiveListData;
    }
    return _effectiveListData.where((item) {
      final String itemName = item.toLowerCase();
      return itemName.contains(filter.toLowerCase());
    }).toList();
  }
}

Widget _customPopupItemBuilderExample2(
    BuildContext context, String item, bool isSelected) {
  return Container(
    margin: const EdgeInsets.all(8),
    decoration: !isSelected
        ? null
        : BoxDecoration(
            border: Border.all(color: AppColors.acYellowWarm),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
    child: ListTile(
      textColor: AppColors.acBlack,
      selected: isSelected,
      title: Text(item),
    ),
  );
}

