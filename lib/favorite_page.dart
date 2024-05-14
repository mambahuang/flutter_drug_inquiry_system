import 'package:flutter/material.dart';

class FavoriteDrug extends StatelessWidget {
  const FavoriteDrug({
    super.key,
    required this.favoriteDrugNames,
    required this.favoriteDrugNamesContent,
    required this.imgSrcList,
  });

  final List<String> favoriteDrugNames;
  final List<String> favoriteDrugNamesContent;
  final List<String> imgSrcList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text("喜愛藥物"),
        ),
        body: Card(
          color: Colors.indigo[50],
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: favoriteDrugNames.length,
                  itemBuilder: (context, index) {
                    // Return a ListTile for each item in the list
                    return ListTile(
                      title:
                          Text(favoriteDrugNames[index]), // Display the string
                      subtitle: Text(favoriteDrugNamesContent[index]),
                      trailing: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 90,
                          minHeight: 90,
                          maxWidth: 100,
                          maxHeight: 100,
                        ),
                        child:
                            Image.network(imgSrcList[index], fit: BoxFit.cover),
                      ),
                      onTap: () {
                        // Handle onTap event if needed
                        print('Tapped on ${favoriteDrugNames[index]}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
