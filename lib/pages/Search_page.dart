import 'dart:async';

import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../helper/CommonFunctions.dart';
import '../helper/Constants.dart';
import '../models/ContentModel.dart';
import 'lectures.dart';
import 'news_detail.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final PagingController<int, ContentModel> _pagingController =
  PagingController<int, ContentModel>(firstPageKey: 0);

  FilterState? filterState;
  final HitsSearcher _contentSearcher = HitsSearcher(
      applicationID: Algolia.applicationId,
      apiKey: Algolia.apiKey,
      indexName: Algolia.indexName);

  // Stream<AlgoliaHitPages> get _searchStream =>
  //     _contentSearcher.responses.map(AlgoliaHitPages.fromResponse);

  Stream<AlgoliaHitPages> get _searchStream => _contentSearcher.responses.transform(
    StreamTransformer.fromHandlers(
      handleData: (response, sink) {
        if (_searchController.text.trim().isEmpty && response.page == 0) {
          // Limit to first 5 items if search query is empty
          sink.add(AlgoliaHitPages.fromResponse(response, limit: 3));
        } else {
          sink.add(AlgoliaHitPages.fromResponse(response));
        }
      },
    ),
  );

  @override
  void initState() {
    /// Listens for changes in the search controller and applies the new query and resets the page.
    _searchController.addListener(() => _contentSearcher.applyState(
            (state) => state.copyWith(query: _searchController.text.trim(), page: 0)));

    /// Listens for new pages of results from the search stream.
    _searchStream.listen((page) {
      if (page.pageKey == 0) {
        /// Refreshes the paginated view if it's the first page.
        _pagingController.refresh();
      }
      _pagingController.appendPage(page.contentList!, page.nextPageKey);
    }).onError((onError) => _pagingController.error = onError);

    /// Listens for page requests from the paging controller.
    _pagingController.addPageRequestListener((pageKey) =>
        _contentSearcher.applyState((state) => state.copyWith(page: pageKey)));

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _contentSearcher.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for Content',
            border: InputBorder.none,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Implement back button functionality
            Navigator.pop(context);
          },
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.mic, color: Colors.black),
        //     onPressed: () {
        //       // Implement microphone functionality
        //     },
        //   ),
        // ],
      ),
      body: CustomScrollView(
        slivers: [
          PagedSliverList<int, ContentModel>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<ContentModel>(
              itemBuilder: (context, item, index) => ListTile(
                title: Text(item.title!),
                onTap: () {
                  Navigator.push(
                      context,
                      CommonFunctionClass.pageRouteBuilder(
                          NewsDetailPage(contentModel: item)));
                },
              ),
              noItemsFoundIndicatorBuilder: (context) =>
                  Center(child: Text('No Content found')),
              newPageProgressIndicatorBuilder: (context) =>
                  Center(child: CircularProgressIndicator()),
              firstPageProgressIndicatorBuilder: (context) =>
                  Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class AlgoliaHitPages {
  final int? nbHits;
  final int? pageKey;
  final int? nextPageKey;
  List<ContentModel>? contentList = [];

  AlgoliaHitPages({this.nbHits, this.pageKey, this.nextPageKey, this.contentList});

  static AlgoliaHitPages fromResponse(SearchResponse response, {int limit = -1}) {
    final isLastPage = response.page >= response.nbPages;
    final nextPageKey = isLastPage ? null : response.page + 1;

    // Convert hits to ContentModel objects
    List<ContentModel> contentJSON = response.hits.map(ContentModel.toObject).toList();

    // Filter the content based on type
    contentJSON = contentJSON.where((item) => [2, 3, 4].contains(item.type)).toList();

    // Apply limit if necessary
    if (limit > 0 && contentJSON.length > limit) {
      contentJSON = contentJSON.take(limit).toList();
    }

    return AlgoliaHitPages(
      nbHits: response.nbHits,
      pageKey: response.page,
      nextPageKey: nextPageKey,
      contentList: contentJSON,
    );
  }
}


// class ContentModel {
//   final String title;
//   // final String content;
//
//   ContentModel({required this.title,
//     // required this.content
//   });
//
//   static ContentModel toObject(Map<String, dynamic> json) {
//     return ContentModel(
//       title: json['title'] as String,
//       // content: json['content'] as String,
//     );
//   }
// }

