define(['jquery'], function($) {
 
    return {
        init: function() {
            $(".filter_simplequestion_buttoncontainer").click(function() {
                $(".filter_simplequestion_container").toggle();
            });
        }
    };
});