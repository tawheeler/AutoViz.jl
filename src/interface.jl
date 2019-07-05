function render!(
    rendermodel::RenderModel,
    scene::EntityFrame{S,D,I};
    car_color::Colorant=_colortheme["COLOR_CAR_OTHER"], # default color
    car_colors::Dict{I,C}=Dict{I,Colorant}(), #  id -> color
    ) where {S,D,I,C<:Colorant}

    for veh in scene
        render!(rendermodel, veh, get(car_colors, veh.id, car_color))
    end

    rendermodel
end

function render(roadway::R;
    canvas_width::Int=DEFAULT_CANVAS_WIDTH,
    canvas_height::Int=DEFAULT_CANVAS_HEIGHT,
    rendermodel = RenderModel(),
    cam::Camera = FitToContentCamera(),
    surface::CairoSurface = CairoSVGSurface(IOBuffer(), canvas_width, canvas_height)
    ) where {R<:Roadway}

    ctx = creategc(surface)
    clear_setup!(rendermodel)
    render!(rendermodel, roadway)
    camera_set!(rendermodel, cam, canvas_width, canvas_height)
    render(rendermodel, ctx, canvas_width, canvas_height)
    return surface
end

function render(ctx::CairoContext, scene::EntityFrame{S,D,I}, roadway::R;
    rendermodel::RenderModel=RenderModel(),
    cam::Camera=SceneFollowCamera(),
    car_colors::Dict{I,C}=Dict{I,Colorant}(),
    ) where {S,D,I,R,C<:Colorant}

    canvas_width = floor(Int, Cairo.width(ctx))
    canvas_height = floor(Int, Cairo.height(ctx))

    clear_setup!(rendermodel)

    render!(rendermodel, roadway)
    render!(rendermodel, scene, car_colors=car_colors)

    camera_set!(rendermodel, cam, scene, roadway, canvas_width, canvas_height)

    render(rendermodel, ctx, canvas_width, canvas_height)
    ctx
end
function render(scene::EntityFrame{S,D,I}, roadway::R;
    canvas_width::Int=DEFAULT_CANVAS_WIDTH,
    canvas_height::Int=DEFAULT_CANVAS_HEIGHT,
    rendermodel::RenderModel=RenderModel(),
    cam::Camera=SceneFollowCamera(),
    car_colors::Dict{I,C}=Dict{I,Colorant}(), # id
    surface::CairoSurface = CairoSVGSurface(IOBuffer(), canvas_width, canvas_height)
    ) where {S,D,I,R, C<:Colorant}

    ctx = creategc(surface)
    render(ctx, scene, roadway, rendermodel=rendermodel, cam=cam, car_colors=car_colors)

    return surface
end

function get_pastel_car_colors(scene::EntityFrame{S,D,I}; saturation::Float64=0.85, value::Float64=0.85) where {S,D,I}
    retval = Dict{I,Colorant}()
    n = length(scene)
    for (i,veh) in enumerate(scene)
        retval[veh.id] = convert(RGB, HSV(180*(i-1)/max(n-1,1), saturation, value))
    end
    return retval
end