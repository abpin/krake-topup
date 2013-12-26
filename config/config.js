{
  "development": {
    "postgres" :{
      "username" : "prod",
      "password" : "Explore123!",
      "host" : "localhost",
      "port" : "5432",
      "database" : "scraped_data_repo_development"
    },    
    "userDataDB" : "dev_panel_development",
    "apiServer" : "http://localhost:9800"
  },
  "production": {
    "postgres" : {
      "username" : "prod",
      "password" : "Explore123!",
      "host" : "krake.io",
      "port" : "5432",
      "database" : "scraped_data_repo"
    },    
    "userDataDB" : "dev_panel",    
    "apiServer" : "https://api.krake.io",
    "authServer" : "http://auth.krake.io"
  }
}