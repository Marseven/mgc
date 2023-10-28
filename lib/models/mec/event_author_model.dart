import 'dart:convert';

EventAuthorModel eventAuthorModelFromJson(String str) =>
    EventAuthorModel.fromJson(json.decode(str));

String eventAuthorModelToJson(EventAuthorModel data) =>
    json.encode(data.toJson());

class EventAuthorModel {
  int id;
  String name;
  String url;
  String description;
  String link;
  String slug;
  Map<String, String> avatarUrls;
  Meta meta;
  List<dynamic> acf;
  bool isSuperAdmin;
  WoocommerceMeta woocommerceMeta;
  bool isUserVerified;
  Links links;

  EventAuthorModel({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.link,
    required this.slug,
    required this.avatarUrls,
    required this.meta,
    required this.acf,
    required this.isSuperAdmin,
    required this.woocommerceMeta,
    required this.isUserVerified,
    required this.links,
  });

  factory EventAuthorModel.fromJson(Map<String, dynamic> json) =>
      EventAuthorModel(
        id: json["id"],
        name: json["name"],
        url: json["url"],
        description: json["description"],
        link: json["link"],
        slug: json["slug"],
        avatarUrls: Map.from(json["avatar_urls"])
            .map((k, v) => MapEntry<String, String>(k, v)),
        meta: Meta.fromJson(json["meta"]),
        acf: List<dynamic>.from(json["acf"].map((x) => x)),
        isSuperAdmin: json["is_super_admin"],
        woocommerceMeta: WoocommerceMeta.fromJson(json["woocommerce_meta"]),
        isUserVerified: json["is_user_verified"],
        links: Links.fromJson(json["_links"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "url": url,
        "description": description,
        "link": link,
        "slug": slug,
        "avatar_urls":
            Map.from(avatarUrls).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "meta": meta.toJson(),
        "acf": List<dynamic>.from(acf.map((x) => x)),
        "is_super_admin": isSuperAdmin,
        "woocommerce_meta": woocommerceMeta.toJson(),
        "is_user_verified": isUserVerified,
        "_links": links.toJson(),
      };
}

class Links {
  List<Collection> self;
  List<Collection> collection;

  Links({
    required this.self,
    required this.collection,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: List<Collection>.from(
            json["self"].map((x) => Collection.fromJson(x))),
        collection: List<Collection>.from(
            json["collection"].map((x) => Collection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "self": List<dynamic>.from(self.map((x) => x.toJson())),
        "collection": List<dynamic>.from(collection.map((x) => x.toJson())),
      };
}

class Collection {
  String href;

  Collection({
    required this.href,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "href": href,
      };
}

class Meta {
  int bbpTopicCount;
  int bbpReplyCount;
  int bbpLastPosted;
  int gamipressCoinsPoints;
  int gamipressCreditPoints;
  int gamipressGemsPoints;
  int gamipressLevelsRank;

  Meta({
    required this.bbpTopicCount,
    required this.bbpReplyCount,
    required this.bbpLastPosted,
    required this.gamipressCoinsPoints,
    required this.gamipressCreditPoints,
    required this.gamipressGemsPoints,
    required this.gamipressLevelsRank,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        bbpTopicCount: json["_bbp_topic_count"],
        bbpReplyCount: json["_bbp_reply_count"],
        bbpLastPosted: json["_bbp_last_posted"],
        gamipressCoinsPoints: json["_gamipress_coins_points"],
        gamipressCreditPoints: json["_gamipress_credit_points"],
        gamipressGemsPoints: json["_gamipress_gems_points"],
        gamipressLevelsRank: json["_gamipress_levels_rank"],
      );

  Map<String, dynamic> toJson() => {
        "_bbp_topic_count": bbpTopicCount,
        "_bbp_reply_count": bbpReplyCount,
        "_bbp_last_posted": bbpLastPosted,
        "_gamipress_coins_points": gamipressCoinsPoints,
        "_gamipress_credit_points": gamipressCreditPoints,
        "_gamipress_gems_points": gamipressGemsPoints,
        "_gamipress_levels_rank": gamipressLevelsRank,
      };
}

class WoocommerceMeta {
  String variableProductTourShown;
  String activityPanelInboxLastRead;
  String activityPanelReviewsLastRead;
  String categoriesReportColumns;
  String couponsReportColumns;
  String customersReportColumns;
  String ordersReportColumns;
  String productsReportColumns;
  String revenueReportColumns;
  String taxesReportColumns;
  String variationsReportColumns;
  String dashboardSections;
  String dashboardChartType;
  String dashboardChartInterval;
  String dashboardLeaderboardRows;
  String homepageLayout;
  String homepageStats;
  String taskListTrackedStartedTasks;
  String helpPanelHighlightShown;
  String androidAppBannerDismissed;

  WoocommerceMeta({
    required this.variableProductTourShown,
    required this.activityPanelInboxLastRead,
    required this.activityPanelReviewsLastRead,
    required this.categoriesReportColumns,
    required this.couponsReportColumns,
    required this.customersReportColumns,
    required this.ordersReportColumns,
    required this.productsReportColumns,
    required this.revenueReportColumns,
    required this.taxesReportColumns,
    required this.variationsReportColumns,
    required this.dashboardSections,
    required this.dashboardChartType,
    required this.dashboardChartInterval,
    required this.dashboardLeaderboardRows,
    required this.homepageLayout,
    required this.homepageStats,
    required this.taskListTrackedStartedTasks,
    required this.helpPanelHighlightShown,
    required this.androidAppBannerDismissed,
  });

  factory WoocommerceMeta.fromJson(Map<String, dynamic> json) =>
      WoocommerceMeta(
        variableProductTourShown: json["variable_product_tour_shown"],
        activityPanelInboxLastRead: json["activity_panel_inbox_last_read"],
        activityPanelReviewsLastRead: json["activity_panel_reviews_last_read"],
        categoriesReportColumns: json["categories_report_columns"],
        couponsReportColumns: json["coupons_report_columns"],
        customersReportColumns: json["customers_report_columns"],
        ordersReportColumns: json["orders_report_columns"],
        productsReportColumns: json["products_report_columns"],
        revenueReportColumns: json["revenue_report_columns"],
        taxesReportColumns: json["taxes_report_columns"],
        variationsReportColumns: json["variations_report_columns"],
        dashboardSections: json["dashboard_sections"],
        dashboardChartType: json["dashboard_chart_type"],
        dashboardChartInterval: json["dashboard_chart_interval"],
        dashboardLeaderboardRows: json["dashboard_leaderboard_rows"],
        homepageLayout: json["homepage_layout"],
        homepageStats: json["homepage_stats"],
        taskListTrackedStartedTasks: json["task_list_tracked_started_tasks"],
        helpPanelHighlightShown: json["help_panel_highlight_shown"],
        androidAppBannerDismissed: json["android_app_banner_dismissed"],
      );

  Map<String, dynamic> toJson() => {
        "variable_product_tour_shown": variableProductTourShown,
        "activity_panel_inbox_last_read": activityPanelInboxLastRead,
        "activity_panel_reviews_last_read": activityPanelReviewsLastRead,
        "categories_report_columns": categoriesReportColumns,
        "coupons_report_columns": couponsReportColumns,
        "customers_report_columns": customersReportColumns,
        "orders_report_columns": ordersReportColumns,
        "products_report_columns": productsReportColumns,
        "revenue_report_columns": revenueReportColumns,
        "taxes_report_columns": taxesReportColumns,
        "variations_report_columns": variationsReportColumns,
        "dashboard_sections": dashboardSections,
        "dashboard_chart_type": dashboardChartType,
        "dashboard_chart_interval": dashboardChartInterval,
        "dashboard_leaderboard_rows": dashboardLeaderboardRows,
        "homepage_layout": homepageLayout,
        "homepage_stats": homepageStats,
        "task_list_tracked_started_tasks": taskListTrackedStartedTasks,
        "help_panel_highlight_shown": helpPanelHighlightShown,
        "android_app_banner_dismissed": androidAppBannerDismissed,
      };
}
