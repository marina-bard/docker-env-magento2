Docker environment Magento2
===

To run the application:

```
    cp .env.dist .env
    export MAGENTO_BASE_URL=http://magento2.local   // your custom base-url value
    sudo docker-compose build
    sudo docker-compose up magento2
```

Access http://magento2.local in your browser.  
Enjoy!