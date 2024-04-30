**Dave** regularly adds new products to the database and completes missing information via API calls. He has described the process below to show other developers how easy it is to contribute.

---

## Authentication and Header

If you have an app that makes POST calls and you don't want your users to authenticate in Open Food Facts, you can create a global account. Dave has created a global account for the app he is developing with the following credentials:

- `user_id`: myappname
- `password`: 123456
    

---

## Subdomain

Dave wants to define the subdomain for the query as `us`. The subdomain automatically defines the country code (`cc`) and language of the interface (`lc`).

The country code determines that only the products sold in the US are displayed. The language of the interface for the country code US is English.

In this case:

[https://us.openfoodfacts.org/cgi/product_jqm2.pl?​​​​​​​](https://us.openfoodfacts.org/cgi/product_jqm2.pl?​​​​​​​)

---

## Product Barcode

After the version number, the word `code`, followed by its barcode must be added:

[https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004](https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004)

---

## Credentials

Dave adds his user credentials to the call as follows:

[https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004&user_id=myappname&password=](https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004&user_id=myappname&password=)**

---

## Parameters

You can define one or more parameters to add, for example, the brand and the Kosher label:

- `brands`: Häagen-Dazs
- `labels`: kosher
    

The call looks like this:

`POST https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004&user_id=test&password=test&brands=Häagen-Dazs&labels=kosher`

---

## Adding a Comment to your WRITE request.

Use the `comment` parameter to add the id of the user editing the product. The id should not contain any personal data.

**Important!** The user id is not the identifier of an Open Food facts user, but the id generated by your system.

It should be structured as: user-agent + user-id.

**Example**

`comment=Edit by a Healthy Choices 1.2 iOS user - SxGFRZkFwdytsK2NYaDg4MzRVenNvUEI4LzU2a2JWK05LZkFRSWc9PQ`

---

## Adding Additional Information to Existing Fields

To add additional information to existing parameters, add the prefix `add_` to the parameter name.

**Important!** If you don't use the `add_` prefix, the existing values will be deleted.

**Example**

`POST https://us.openfoodfacts.org/cgi/product_jqm2.pl?code=0074570036004&user_id=test&password=test&add_categories=Desserts`

To see the complete list of parameters, see the **Parameters** section.