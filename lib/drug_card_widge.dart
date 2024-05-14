import 'package:flutter/material.dart';

class DrugCardWidget extends StatefulWidget {
  const DrugCardWidget({
    super.key,
    required this.favoriteDrugNames,
    required this.favoriteDrugNamesContent,
    required this.item,
    required this.imgSrc,
    required this.imgSrcList,
  });

  final List<String> favoriteDrugNames;
  final List<String> favoriteDrugNamesContent;
  final List<String> imgSrcList;
  final Map<String, dynamic> item;
  final String imgSrc;

  @override
  State<DrugCardWidget> createState() => _DrugCardWidgetState();
}

class _DrugCardWidgetState extends State<DrugCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (widget.favoriteDrugNames
                      .contains(widget.item['chinese_name'])) {
                    widget.favoriteDrugNames
                        .remove(widget.item['chinese_name']);
                    widget.favoriteDrugNamesContent
                        .remove(widget.item['indication']);
                    if (widget.item['image_link'] == '') {
                      widget.imgSrcList.remove(
                          'https://cyberdefender.hk/wp-content/uploads/2021/07/404-01-scaled.jpg');
                    } else {
                      widget.imgSrcList.remove(widget.item['image_link']);
                    }
                  } else {
                    widget.favoriteDrugNames.add(widget.item['chinese_name']);
                    widget.favoriteDrugNamesContent
                        .add(widget.item['indication']);
                    if (widget.item['image_link'] == '') {
                      widget.imgSrcList.add(
                          'https://cyberdefender.hk/wp-content/uploads/2021/07/404-01-scaled.jpg');
                    } else {
                      widget.imgSrcList.add(widget.item['image_link']);
                    }
                  }
                  debugPrint(widget.favoriteDrugNames.toString());
                  debugPrint(widget.favoriteDrugNamesContent.toString());
                  debugPrint(widget.imgSrcList.toString());
                });
              },
              icon: (widget.favoriteDrugNames
                          .contains(widget.item['chinese_name']) ==
                      true)
                  ? const Icon(Icons.favorite)
                  : const Icon(Icons.favorite_border)
          ),
          Expanded(
            child: ListTile(
              title: Text(widget.item["chinese_name"]),
              subtitle: Text(widget.item["indication"]),
            ),
          ),
          Image.network(
              widget.imgSrc,
              width: 100,
              height: 100
          )
        ],
      ),
    );
  }
}
