angular
  .module 'AngularApplicationBoilerplate', ['ngRoute']
  .config ($routeProvider) ->
    $routeProvider
      .when('/', {
        templateUrl: 'main/main.html'
        controller: 'MainController'
      })
      .otherwise({
        redirectTo: '/'
      })
