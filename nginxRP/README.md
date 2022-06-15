# Nginx reverse proxy with HTTP and HTTPS

Sample configuration file for {{ sitename }} handling both HTTP and HTTPs versions, with an HTTP to HTTPS redirection


You will have to substitute the following:
- %sitename% : the (public) sitename you're proxifying (www.example.com)
- %backend% : The (private) server name or IP running the backend (10.10.1.123)
- %httpPort% : the listening port of the backend server for HTTP
- %httpsPort% : the listening port of the backend server for HTTPS

Mind also to adjust the `/path/to/your/certificate.{key,crt}` options
