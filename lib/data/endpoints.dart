class Endpoints {
  Endpoints._();

  // base url
  //static const String baseUrl = "https://prabodham.rivaaninfotech.com/api";
  static const String baseUrl = "http://www.api.prabodham.com/api";
  //static const String baseUrl = "http://192.168.0.104:8000/api";

  // receiveTimeout
  static const int receiveTimeout = 5000;

  // connectTimeout
  static const int connectionTimeout = 50000;

  //app version
  static const String appVersion = '/appVersion';

  //user api endpoint
  static const String signUp = '/customerSignUp';
  static const String signIn = '/customerLogIn';
  static const String updateUserDetails = "/customerUpdateProfile";
  static const String resetPassword = '/customerResetPassword';
  static const String forgotPassword = '/forgotPassword';
  static const String getUserDetails = '/getCountOfMyReviewAddressOrder';

  //address api endpoint
  static const String addAddress = '/addCustomerAddress';
  static const String getAddress = '/getCustomerAddress';
  static const String updateAddress = '/updateCustomerAddress';
  static const String updateDefaultAddress = '/setDefaultAddress';
  static const String deleteAddress = '/deleteCustomerAddress';
  static const String getCountries = '/getListOfCountries';

  //product api endpoint
  static const String getProductById = '/getProductById';
  static const String bestSellerProducts = '/bestSellingProduct';
  static const String newArrivalProducts = '/newArrival';
  static const String getProductByCategory = '/getProductByCategory';
  static const String getProductBySearch = '/searchProductDashBoard';
  static const String getFavouriteProduct = '/getListOfFavouriteByCustomer';
  static const String getRecommendedProduct = '/';
  static const String addProductFavourite = '/addFavourite';
  static const String removeProductFavourite = '/removeFavourite';
  static const String updateProductFavourite = '/updateFavourite';

  //dashboard api endpoint
  static const String getBannerImages = '/getSliderData';
  static const String getWallet = '/getWalletByCustomerId';

  //promoCode api endpoint
  static const String getPromoCodes = '/getListOfPromocode';

  //review api endpoint
  static const String postReview = '/addReview';
  static const String getReviewByProduct = '/getReviewByProduct';
  static const String getMyReview = '/getReviewByCustomer';

  //order api endpoint
  static const String getAllOrders = '/getAllOrderOfCustomer';
  static const String postOrder = '/recordOrder';
  static const String getOrderById = '/getOrderDetails';
  static const String getAvailability = '/checkProductAvailability';
  static const String deleteOrderById = '/cancelOrder';

  //cart api endpoint
  static const String getCart = '/getCartByCustomerId';
  static const String updateCart = '/updateCart';
  static const String getCartDetail = '/getCartItemsCount';

  //
  static const String getWalletTransaction = "/walletTransaction";
  static const String getReferralTransaction = "/referralTransaction";
  //categories api endpoint
  static const String getCategories = '/getCategoryList';

  //t&c and privacy policy
  static const String privacyPolicy = 'https://prabodham.com/privacy-policy/';
  static const String termsAndCondition = 'https://prabodham.com/terms-of-use/';
}
