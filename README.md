Docker environment Magento2
===

To run the application:

```
    cp .env.dist .env                               // check .env for valid values
    export MAGENTO_BASE_URL=http://magento2.local   // your custom base-url value
    sudo -E docker-compose up --build magento2
```

Access Magento Home Page by http://magento2.local in your browser.  
Access Magento Admin by http://magento2.local/admin with:  

> login: admin  
> password: admin123  

Enjoy!
