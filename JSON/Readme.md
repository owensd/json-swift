

    {
        "stat": "ok",
        "blogs": {
            "blog": [
                {
                    "id" : 73,
                    "name" : "Bloxus test",
                    "needspassword" : false,
                    "url" : "http://remote.bloxus.com/"
                },
                {
                    "id" : 74,
                    "name" : "Manila Test",
                    "needspassword" : true,
                    "url" : "http://flickrtest1.userland.com/"
                }
            ]
        }
    }


let blog1_id = JSON(json)["blogs"]["blog"][0]["id"].number