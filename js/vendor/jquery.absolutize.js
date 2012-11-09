         (function($){
            $.fn.absolutize = function() {
                var elems = [];
                this.each(function() {
                    var element = $(this);

                    if (element.css('position') == 'absolute') return;

                    var offset = element.offset();
                    elems.push({
                        el: element,
                        newRules: {
                            position: 'absolute',
                            top: offset.top,
                            left: offset.left,
                            margin: 0,
                            padding: 0
                        }
                    });
                });

                $.each(elems, function(i, obj){
                    obj.el.css( obj.newRules );
                });
            };
        })(jQuery);