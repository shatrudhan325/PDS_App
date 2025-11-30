class Routes {
  static const LOGIN = '/login';
  static const DISTRICT_ENGINEER = '/district_engineer';
  static const BLOCK_ENGINEER = '/block_engineer';
  static const FORBIDDEN = '/forbidden';
}

const routeForRole = {
  "DISTRICT_ENGINEER": Routes.DISTRICT_ENGINEER,
  "BLOCK_ENGINEER": Routes.BLOCK_ENGINEER,
};
