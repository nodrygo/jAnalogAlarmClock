#=
using Pkg
Pkg.generate("jAnalogAlarmClock")
Pkg.activate("jAnalogAlarmClock")
Pkg.add(PackageSpec(url="https://github.com/JuliaGraphics/Gtk.jl", rev="master"))
Pkg.add(PackageSpec(url="https://github.com/JuliaGraphics/Luxor.jl", rev="master"))
Pkg.add(PackageSpec(url="https://github.com/JuliaGraphics/ColorSchemes.jl", rev="master"))
=#

#=
##########################
# WITH PackageCompiler.jl WORK only with modied C code
##########################
using PackageCompiler

build_executable("./jAnalogAlarmClock/src/alarmClock.jl",
"alarmClock","./jAnalogAlarmClock/src/program.c";
builddir = "./jAnalogAlarmClock/bin",
release = true, Release = true)

#############################
# WITH ApplicationBuilder.jl  BUG
/home/ygo/.julia/packages/PackageCompiler/oT98U/examples/program.c:43:5: internal compiler error: Erreur du bus
     for (i = 1; i < argc; i++) {
#############################

OLD Pkg.add(PackageSpec(url="https://github.com/NHDaly/ApplicationBuilder.jl", rev="master"))
Pkg.add(PackageSpec(url="https://github.com/JuliaLang/PackageCompiler.jl/", rev="master"))

using ApplicationBuilder
build_app_bundle("$(homedir())/julia/jAnalogAlarmClock/src/alarmClock.jl";
                 builddir="$(homedir())/julia/jAnalogAlarmClock/BINjClock" ,
                 appname="jClock", verbose=true,
                 create_installer=true)


=#
module jAnalogAlarmClock
    using Colors, Cairo, Compat, FileIO
    using Gtk
    using Luxor
    global L=Luxor
    include("drawclock.jl")
    global winx = 260
    global winy = 260
    global curcolor = "white"

    function callClock(tt)
            drawclock(60)
            Gtk.draw(c)
    end
    function mydraw()
        L.background(curcolor) # hide
        drawclock(60)
    end
    function cbresize(w)
            wdth, hght = screen_size(w)
            #wzize = get_gtk_property(w, :size_request)
            println("Windows changed $wdth $hght")
    end
    function mainwin()
        # main win
        win = GtkWindow("alarmclock",winx,winy)
        # screen = get_gtk_property(win, :screen,GdkScreen)
        # get_gtk_property(screen, :rgba_colormap, GdkColormap)
        # set_gtk_property!(win, :visual , 0.9)
        vbox = GtkBox(:v)
        #gtk canvas
        global c = Gtk.Canvas(winx,winy)
        # create luxor drawing
        global currentdrawing =  L.Drawing(winx,winy, "alarmClock.png")
        global luxctx = currentdrawing.cr



        # Define the popup menu
        popupmenu = Gtk.Menu()
        setAlarm = Gtk.MenuItem("Set Alarm")
        switchDeco = Gtk.MenuItem("Switch decoration")
        push!(popupmenu, setAlarm)
        push!(popupmenu, switchDeco)

        c.mouse.button3press = (widget,event) -> popup(popupmenu, event)

        signal_connect(setAlarm, :activate) do widget
            println("open set alarm dialog")
        end

        signal_connect(switchDeco, :activate) do widget
            if get_gtk_property(win, :decorated, Bool)
                set_gtk_property!(win, :decorated ,false)
            else
                set_gtk_property!(win, :decorated ,true)
            end
        end

        signal_connect(win, :configure_event ) do widget
            cbresize(win)
        end
        @guarded Gtk.draw(c) do widget
            ctx = Gtk.getgc(c)
            mydraw()
            Cairo.set_source_surface(ctx, currentdrawing.surface, 0, 0)
            Cairo.paint(ctx)
            Gtk.fill(ctx)
            Gtk.reveal(c)
        end

        #set_gtk_property!(win, :decorated ,false)
        set_gtk_property!(win, :opacity , 0.9)
        # set_gtk_property!(vbox, :opacity , 0.9)
        set_gtk_property!(c, :opacity , 0.9)

        push!(win, vbox)
        push!(vbox, c)

        showall(win)
        # This next line is crucial: otherwise your popup menu shows as a thin bar
        Gtk.showall(popupmenu)

        # create and set timer
        global tt = Timer(callClock, 1, interval = 1.0)

        win
    end

    # function main for static compiler
    Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
        win = mainwin()
    	if !isinteractive()
    	    c = Condition()
    	    signal_connect(win, :destroy) do widget
    		notify(c)
    	    end
    	    wait(c)
    	end
        return 0
    end

# if interactive kill timer when destroy win
    if isinteractive()
        win = mainwin()
        signal_connect(win, :destroy) do widget
                close(alarmclock.tt)
        end
    end
end
