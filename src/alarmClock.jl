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

Pkg.add(PackageSpec(url="https://github.com/NHDaly/ApplicationBuilder.jl", rev="master"))

using ApplicationBuilder
build_app_bundle("$(homedir())/julia/jAnalogAlarmClock/src/alarmClock.jl";
                 builddir="$(homedir())/julia/jAnalogAlarmClock/BINjClock" ,
                 appname="jClock", verbose=true)


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
    # global models = ["text", "stars", "eggs","clock","colornames","spiral","strangeloop"]
    # global french_months = ["janvier", "février", "mars", "avril","mai", "juin","juillet", "août", "septembre", "octobre","novembre", "décembre"];
    # global french_monts_abbrev=["janv","févr","mars","avril","mai","juin","juil","août","sept","oct","nov","déc"];
    # global french_days=["lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche"];
    # global Dates.LOCALES["french"] = Dates.DateLocale(french_months,french_monts_abbrev,french_days, [""]);

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
        vbox = GtkBox(:v)
        #gtk canvas
        global c = Gtk.Canvas(winx,winy)
        # create luxor drawing
        global currentdrawing =  L.Drawing(winx,winy, "alarmClock.png")
        global luxctx = currentdrawing.cr
        #gtk canvas
        btnquit  = Gtk.Button("set alarm")

        signal_connect(btnquit, :clicked) do widget
            exit()
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

        #setproperty!(vbox,:border_width,1)
        push!(win, vbox)
        push!(vbox, c)
        push!(vbox, btnquit)
        showall(win)
        global tt = Timer(callClock, 1, interval = 1.0)

        #set_gtk_property!(win, :decorated ,false)
        #set_gtk_property!(c, :opacity , 0.5)

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
# julia  -L alarmClock.jl -e 'jAnalogAlarmClock.julia_main([""])'
