         (function($){
            $.fn.bodysnatch = function() {
                rA = []
                this.each(function() {
                    var element = $(this);
                    var clone = element.clone();
                    element.css('visibility','hidden')
                    //element.css('color','gray')
                    clone.css({
                        position: 'absolute',
                        top: element.offset().top,
                        left: element.offset().left,
                        margin:0,
                        padding:0,
                        border: '0px solid black'
                        })
                    rA.push(clone)
                    $('body').append(clone)
                });
                return rA;
            };
        })(jQuery);