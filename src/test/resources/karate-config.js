function() {
  var env = karate.env || 'dev';
  karate.log('karate.env system property was:', env);

  var config = {
    env: env,
    apiUrl: 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api' //'http://localhost:8080/testuser/api'
  };

  var globalHeaders = read('classpath:data/headers.json');
  karate.configure('headers', globalHeaders);

  return config;
}
