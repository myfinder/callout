$(function(){
    var characters = ["blowfish", "celebration", "dog4", "sheep1", "silhouette2"];

    $(".js-syllabary").click(function () {
        var index = $(this).data("index");

        $("ul#member-list li").each(function (i) {
            if($(this).data("syllabary-index") === index) {
                $(this).show();
            }
            $("#office-vistiors-content").hide();
            $("#staff-vistiors-content").hide();
            $(".js-return-view-list").show();
        });
    });

    $('.js-return-view-list').click(function () {
        $("#office-vistiors-content").show();
        $("#staff-vistiors-content").show();
        $(".js-return-view-list").hide();

        $("ul#member-list li").each(function (i) {
            $(this).hide();
        });
    });

    $('.js-call').click(function() {
        var params = $(this).find("form").serialize();
        var randnum = Math.floor( Math.random() * characters.length );

        $("#character").removeClass();
        $("#character").addClass("character");
        $(".overlay").show();

        $.post( "/message", params,
            function() {
                $("#response-message").show();
            })
            .done(function() {
                $("#character").addClass("flaticon-" + characters[randnum]);
                $("#character").effect("bounce", {}, 4000);
                setTimeout(function(){
                    $("#response-message").fadeOut("slow");
                    $(".overlay").hide();
                    $("#office-vistiors-content").show();
                    $("#staff-vistiors-content").show();
                    $(".js-return-view-list").hide();

                    $("ul#member-list li").each(function (i) {
                        $(this).hide();
                    });
                },5000);
            })
            .fail(function() {
                $("#response-error-message").show();
                setTimeout(function(){
                    $("#response-error-message").fadeOut("slow");
                    $(".overlay").hide();
                },10000);
            })
            .always(function() {
            });

    });
});
