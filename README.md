![splash image](images/jClock.png)

# jAnalogAlarmClock
analogic alarm clock Julia/Gtk/Luxor    

# AOT compiler

```
using Pkg
Pkg.add(PackageSpec(url="https://github.com/NHDaly/ApplicationBuilder.jl", rev="master"))
using ApplicationBuilder
build_app_bundle("$(homedir())/julia/jAnalogAlarmClock/src/alarmClock.jl";
                 builddir="$(homedir())/julia/jAnalogAlarmClock/BINjClock" ,
                 appname="jClock", verbose=true,
                 create_installer=true)
```

A bug  give an error IO bus     
due to Arg handle in `program.c` code so I have comment the `for (i = 1; i < argc; i++) { ...}`    
and now work but without Args     



unfortunatly binary is very very big and start time soooo long compared to the [Racket one](https://github.com/nodrygo/RktAlarmClock)


alarm not yet done    
popu menu [DONE]    


for transparent windows [Gtk.jl see to much unfinished]   
```
gboolean supports_alpha = FALSE;
static void screen_changed(GtkWidget *widget, GdkScreen *old_screen, gpointer userdata)
{
    /* To check if the display supports alpha channels, get the colormap */
    GdkScreen *screen = gtk_widget_get_screen(widget);
    GdkColormap *colormap = gdk_screen_get_rgba_colormap(screen);

    if (!colormap)
    {
        printf("Your screen does not support alpha channels!\n");
        colormap = gdk_screen_get_rgb_colormap(screen);
        supports_alpha = FALSE;
    }
    else
    {
        printf("Your screen supports alpha channels!\n");
        supports_alpha = TRUE;
    }

    /* Now we have a colormap appropriate for the screen, use it */
    gtk_widget_set_colormap(widget, colormap);
}
```
