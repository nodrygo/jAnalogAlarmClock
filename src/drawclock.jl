using Dates, Luxor
french_months = ["janvier", "février", "mars", "avril","mai", "juin","juillet", "août", "septembre", "octobre","novembre", "décembre"];
french_monts_abbrev=["janv","févr","mars","avril","mai","juin","juil","août","sept","oct","nov","déc"];
french_days=["lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche"];
Dates.LOCALES["french"] = Dates.DateLocale(french_months,french_monts_abbrev,french_days, [""]);
t=now()

function drawneedle(l)
    p0  = Luxor.Point(1,1)
    pp1 = Luxor.Point(5,l/3)
    pp2 = Luxor.Point(0,l)
    pp3 = Luxor.Point(-5,l/3)
    Luxor.setline(3)
    ptlist = [p0,pp1,pp2,pp3]
    ptlist2 = [p0,pp1+(2, 0),pp2,pp3-(2, 0)]
    Luxor.sethue("ivory")
    Luxor.poly(ptlist, :fill, close=true)
    Luxor.sethue("gold4")
    Luxor.poly(ptlist2, :stroke, close=true)

end
function drawclock(radius, action=:none)
    t  = Dates.now()
    txtday = Dates.dayname(t ; locale="french")
    txtmonth = Dates.monthname(t ; locale="french")
    s  = Dates.second(t)
    m  = Dates.minute(t)
    h  = Dates.hour(t)
    p0 = Luxor.Point(0,0)
    Luxor.origin()
    Luxor.setopacity(0.7)
    Luxor.background("lavender")
    Luxor.sethue("black")
    Luxor.setline(1)
    Luxor.circle(0,0, radius+60, :stroke)
    #draw 12 lines
    ht = 12
    for theta in range(0, step=pi/6, length=12)
        Luxor.@layer begin
            Luxor.rotate(theta)
            Luxor.translate(0, -radius-40)
            Luxor.sethue("black")
            Luxor.setline(3)
            Luxor.line(p0,Luxor.Point(0,10), :stroke)
            Luxor.translate(0, -2)
            fontface("Agenda-Black")
            fontsize(radius/5)
            Luxor.text("$ht" ,0,0,halign=:center)
            if ht >11
                ht = 0
            end
            ht += 1
        end
    end
    # draw quarters
    for theta in range(0, step=pi/2, length=4)
        starsize = radius/10
        Luxor.@layer begin
            Luxor.rotate(theta)
            Luxor.translate(0, -radius-20)
            Luxor.sethue("gold3")
            Luxor.star(0,0, starsize,6, 0.5, 0, :fill)
        end
    end
    # draw seconds
    Luxor.rotate(0)
    for theta in range(0, step=pi/30, length=s+1)
            Luxor.origin()
            Luxor.rotate(theta)
            Luxor.translate(0, -radius-60)
            Luxor.sethue("red")
            Luxor.circle(0,0, 2, :fill)
    end


    #draw drawneedle for minutes
    Luxor.origin()
    Luxor.rotate(pi+(m*(pi/30)))
    drawneedle(radius+25)

    #draw drawneedle for hour
    deltah = h /60
    Luxor.origin()
    Luxor.rotate(pi+((deltah + h) * (pi/6)))
    drawneedle(radius-15)

    Luxor.origin()
    Luxor.sethue("black")
    Luxor.circle(0,0, 10, :fill)
    Luxor.sethue("blue")
    fontface("Agenda-Black")
    fontsize(20)
    Luxor.text(Dates.format(t, "E d U";locale="french"),0,-20 ,halign=:center)
    Luxor.text(Dates.format(t, "yyyy"),0, -40 ,halign=:center)
    fontsize(30)
    Luxor.text(Dates.format(t, " HH:MM:SS"),0,50,halign=:center)
end
