class View
    moveable: ['X', 'Y']

    constructor: ->

        if 'X' in @moveable or 'Y' in @moveable
            @element[0].addEventListener('touchstart',
                        ((event) => @touchStart(event)), false)
            @element[0].addEventListener('touchend',
                        ((event) => @touchEnd(event)), false)
            @element[0].addEventListener('touchmove',
                        ((event) => @touchMove(event)), false)

            @touchStartPoint = {
                'x': 0
                'y': 0
            }

    append: (child) ->
        @element.append(child)

    touchStart: (event) ->
        if event.targetTouches.length == 1
            event.preventDefault()
            touch = event.targetTouches[0]
            @touchStartPoint = {
                'x': touch.pageX,
                'y': touch.pageY
            }

            @elementStartPoint = {
                'x': (parseInt(@element.css('left'), 10) or 0),
                'y': (parseInt(@element.css('top'), 10) or 0)
            }

            @elementPosition = {
                'x': @elementStartPoint.x,
                'y': @elementStartPoint.y
            }

    touchEnd: (event) ->
        @touchDirection = null

    touchMove: (event) ->
        if event.targetTouches.length == 1
            event.preventDefault()
            touch = event.targetTouches[0]
            delta = {
                'x': touch.pageX - @touchStartPoint.x,
                'y': touch.pageY - @touchStartPoint.y
            }
            if not @touchDirection
                # Y is prioritized
                if (Math.abs(delta.x) > Math.abs(delta.y))
                    @touchDirection = 'X'
                else
                    @touchDirection = 'Y'

            # Place element where the finger is

            if 'X' in @moveable and @touchDirection is 'X'
                @elementPosition.x = delta.x + @elementStartPoint.x
            if 'Y' in @moveable and @touchDirection is 'Y'
                @elementPosition.y = delta.y + @elementStartPoint.y
            if not @timer
                @timer = setTimeout((() => @updatePosition()), 1)

    updatePosition: ->
        @timer = clearTimeout(@timer)
        @element.css('left', @elementPosition.x)
        @element.css('top', @elementPosition.y)

class Image extends View

    moveable: ['X']

    template: ->
        """
        <div class="image-container">
            <img class="image" id="image-#{@id}" src="#{@src or ''}" />
        </div>
        """

    constructor: (@id, @src) ->
        @element = $(@template())
        super

    render: ->
        @element

class ImageContainer extends View

    moveable: ['Y']

    template: ->
        """
        <section id="#{@id}" class="images">
        </section>
        """

    constructor: (@id, @slots) ->
        @element = $(@template())
        @images = (new Image(num) for num in [1..@slots])
        super


    render: ->
        @append(image.render()) for image in @images
        @element


class Remindagram
    constructor: (slots) ->
        numSlots = 6
        @imageContainer = new ImageContainer('images', numSlots)
        $('#body').append(@imageContainer.render())
        $('#body')[0].addEventListener('touchmove',
                    ((event) -> event.preventDefault()), false)

init = () ->
    app = new Remindagram(6)

$(document).ready(init)
