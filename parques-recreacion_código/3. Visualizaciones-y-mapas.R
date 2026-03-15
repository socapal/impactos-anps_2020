#******************************************************************************#
#Nombre: Visualizaciones y mapas    
#Fecha de última actualización: 22/3/2022                              
#Proyecto: Trabajo de grado    
#Creador: Sebastián Ocampo Palacios (asesor Manuel A. Bautista-Gónzalez)
#******************************************************************************#

# 1. Librerías  -----------------------------------------------------------------------

rm (list=ls())
paquetes=c("dplyr","tidyr", "ggplot2", "sf", "lwgeom", "beepr",
           "readxl", "colorspace")

sapply(paquetes, 
       function (x){
         if(! x %in% rownames(installed.packages()))
           install.packages(x)
         require(x, character.only=T)
       })

# Encripción y directorio (bases de datos)
Sys.setlocale("LC_ALL", "ES_ES.UTF-8")
setwd("D:/parques-recreacion_impacto-anps/")

# Podemos agregar fuentes (TNR)
windowsFonts(Times=windowsFont("Times New Roman"))

# MGI
mgi=st_read("datasets-brutas/shp/mun/00mun.shp")

# ANPS
anps=st_read("datasets-brutas/shp/anps/183ANP_Geo_ITRF15Diciembre_2021.shp")

# Homologamos sistema de coordenadas para ambas bases
anps=st_transform(anps,6372); mgi=st_transform(mgi, 6372);st_crs(anps)==st_crs(mgi)

# Ajustamos nuestras bases para mapas
mgi=mgi %>% filter(CVEGEO!="04013") %>% filter(CVEGEO!="02007")

# Adelante necesitaremos incluir datos de marginación e ingreso...
datos_marginacion= data %>% select(c(CVEGEO, IM_2020, IMN_2020, ING_MEDIO_MUN, dummies))
datos_marginacion$IM_2020=round(datos_marginacion$IM_2020, digits=1)
datos_marginacion$ING_MEDIO_MUN=round(datos_marginacion$ING_MEDIO_MUN, digits=0)
mgi=right_join(mgi, datos_marginacion, by="CVEGEO") # Agregamos marginación.


# 2. Mapas-específicos ----------------------------------------------------

# 2.1 Mapa de parejas municipio-anp ---------------------------------------

# ANPs con su municipio más cercano
mgi$cercanas=data$cercanas
centroides_mgi=st_centroid(mgi)   #reduce el tiempo de ejecución
centroides_anps=st_centroid(anps) #  y facilita su visualización

  # Gráfica 
  ggplot()+
  # Asignamos un color gris para los municipios sin ANPs cercanas.
  geom_sf(data=centroides_mgi %>% filter(cercanas==0), color="gray")+
  # Asignamos un color rojizo  a los municipios con ANPs cercanas
  geom_sf(data=centroides_mgi %>% filter(cercanas!=0), color="#C08D34")+
  # Asignamos un color verde a las ANPs
  geom_sf(data=centroides_anps, color="#0E6355", size=1.5)+
  ## geom_sf(data=anps, color="#59886B")+ Con esta línea podemos ver que los 
  ## centroides de anps muy irregulares están claramente mal calculados. 
  
  labs(title="Áreas Naturales y muncipios cercanos",
       subtitle="Municipios que están a 10 kilómetros de un ANP",
       caption="Datos: CONANP, INEGI | Sebastián Ocampo")+
  
  theme(
    text = element_text(color = "Black"),
    plot.background = element_rect(fill = "White", color = NA),
    panel.background = element_rect(fill = "White", color = NA),
    legend.background = element_rect(fill = "#f5f5f2", color = NA),
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 12, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    
    legend.position = c(0.7, 0.09))+
  coord_sf(datum=NA)

# Ahora, queremos agregar dos cosas:


# 2.2 Mapa de propensión --------------------------------------------------

# 1. Índice de propensión
## Necesitamos ejecutar la sección 4 del código 1. Matching-Estadística-desc.R

# Datos incompletos (clave y ps)
incompletos=data[complete.cases(data)==FALSE,] #Casos incompletos
incompletos=as.data.frame(incompletos$CVEGEO)
incompletos$ps=NA
names(incompletos)=c("CVEGEO", "ps")

completos=data.frame(CVEGEO=matching$CVEGEO, ps=m.out$distance)

mgi=right_join(mgi,
  rbind(incompletos, completos), by="CVEGEO")

centroides_mgi=st_centroid(mgi)   #reduce el tiempo de ejecución
 
## Gráfica de PS
PS=ggplot()+
   # Coloreamos por escala para .
  geom_sf(data=centroides_mgi, aes(color=ps))+
  scale_color_continuous(low ="#e0c69b", high="#7a3100", 
                        guide = guide_legend(keyheight = unit(3, units = "mm"),
                                             keywidth=unit(12, units = "mm"), 
                                             label.position = "top", 
                                             title.position = 'top', nrow=1))+
  
  
   # Asignamos un color verde a las ANPs
  geom_sf(data=centroides_anps, color="#0E6355", size=1.5)+
  ## geom_sf(data=anps, color="#59886B")+ Con esta línea podemos ver que los 
  ## centroides de anps muy irregulares están claramente mal calculados. 
  
    labs(title="Distritaciones y área natural protegidas",
       subtitle="Pares de distritos electorales y ANPs con menor distancia",
       caption="Datos: CONANP, INE-INEGI | @sebasdepapel")+
  
  
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.background = element_rect(fill = "White", color = NA),
    legend.background = element_rect(fill = "White", color = NA),
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 12, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    
    legend.position = c(0.2, 0.09))+
  coord_sf(datum=NA)


#png('D:/parques-recreacion_impacto-anps/ilustraciones/ps-preprocessed.png', pointsize=10, width=2100, height=2100, res=300)
#PS
#dev.off()


# Agregamos distancia
# st_nearest_feature(mgi, anps)
distancia=st_distance(st_centroid(mgi),anps[mgi$cercanas,], by_element = TRUE)
plot(x=mgi$ps, y=distancia)

# 2.1 Ejemplo de cajón: Tlalpan -------------------------------------------

# Tlalpan es el municipio con más ANPs cercanas (10).
tlalpan=mgi %>% filter(NOMGEO=="Tlalpan")
tlalpan2= data%>% filter(CVEGEO=="Tlalpan")
st_nearest_feature(st_centroid(tlalpan), anps) # ANP 63 es la más cercana.
mascercana=anps[32,]

cercanas=anps %>% 
  filter(
    st_is_within_distance(anps,tlalpan, dist=10000, sparse=FALSE)==1 
  )

ggplot()+
  geom_sf(data=tlalpan)+
  geom_sf(data=cercanas, fill="green")+
  geom_sf(data=st_centroid(mascercana), fill="#75163F")

TLALPAN= ggplot()+
  geom_sf(data=tlalpan, 
          fill="#C0C0C0", size=1, color = "#C0C0C0") + 
  geom_sf(data=st_centroid(cercanas), aes(fill="#377D22"), size=2, color = "#377D22")+
  geom_sf(data=st_centroid(mascercana), fill="#75163F", size=2, color = "#75163F")+
  geom_sf(data=st_centroid(tlalpan), fill="#FFFFFF", size=1, color = "#FFFFFF")+
  labs(title="Distribución étnica por región", 
       subtitle="Península de Baja California y Pacífico Norte",
       caption="Datos: CONANP, INE-INEGI | @sebasdepapel")+
  
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.background = element_rect(fill = "#f5f5f2", color = NA),
    legend.background = element_rect(fill = "#f5f5f2", color = NA),
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 10, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.43, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    legend.position = c(0.7, 0.09))+
  theme_void()+
  coord_sf(datum=NA)
TLALPAN

# Falta unificar...
data[284,] #Esto se vincula con los datos de tlalpan.
tratadas[151,]
datos_anps[151,]

# 2.1.2 Propensity: Tlalpan ------------------------------------------------

ggplot()+
# Coloreamos por escala para .
geom_sf(data=tlalpan, aes(color=ps))+
  scale_color_continuous(low ="white", high="red", 
                         guide = guide_legend(keyheight = unit(3, units = "mm"),
                                              keywidth=unit(12, units = "mm"), 
                                              label.position = "top", 
                                              title.position = 'top', nrow=1))+
  
  geom_sf(data=st_centroid(cercanas), aes(fill="#377D22"), size=2, color = "#377D22")+
  geom_sf(data=st_centroid(mascercana), fill="#75163F", size=2, color = "#75163F")+
  geom_sf(data=st_centroid(tlalpan), fill="#FFFFFF", size=1, color = "#FFFFFF")+
  labs(title="Distribución étnica por región", 
       subtitle="Península de Baja California y Pacífico Norte",
       caption="Datos: CONANP, INE-INEGI | @sebasdepapel")+
  
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.background = element_rect(fill = "#f5f5f2", color = NA),
    legend.background = element_rect(fill = "#f5f5f2", color = NA),
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 10, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.43, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    legend.position = c(0.7, 0.09))+
  theme_void()+
  coord_sf(datum=NA)

  
rm(tlalpan, tlalpan2,cercanas, mascercana)



# 2.2 Índice de marginación e ingreso (exploración) ---------------------------------
centroides_anps=st_centroid(anps) #  y facilita su visualización
centroides_mgi=st_centroid(mgi)

## Gráfica de PS
ggplot()+
  # Coloreamos por escala para .
    geom_sf(data=centroides_marg, aes(color=IM_2020))+
  
  scale_color_gradient(limits=c(min(mgi$IM_2020), max(mgi$IM_2020)), low ="#7a3100", high="#e0c69b",
  #scale_color_continuous(low ="#7a3100", high="#e0c69b",  
                         guide = guide_legend(keyheight = unit(3, units = "mm"),
                                              keywidth=unit(12, units = "mm"), 
                                              label.position = "top", 
                                              title.position = 'top', nrow=1))+
  
  
  # Asignamos un color verde a las ANPs
  geom_sf(data=centroides_anps, color="#0E6355", size=1.5)+
  ## geom_sf(data=anps, color="#59886B")+ Con esta línea podemos ver que los 
  ## centroides de anps muy irregulares están claramente mal calculados. 
  
  labs(title="Distritaciones y área natural protegidas",
       subtitle="Pares de distritos electorales y ANPs con menor distancia",
       caption="Datos: CONANP, INE-INEGI | @sebasdepapel")+
  
  
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.background = element_rect(fill = "White", color = NA),
    legend.background = element_rect(fill = "White", color = NA),
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 12, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    
    legend.position = c(0.2, 0.09))+
  coord_sf(datum=NA)


centroides_marg=st_centroid(right_join(mgi, 
  filter(datos_marginacion, dummies==0),  #Nos quedamos solamente con las áreas cercanas...
  by="CVEGEO"))  


## Gráfica para cercanas.
ggplot()+
  # Coloreamos por escala para .
  geom_sf(data=centroides_marg, aes(color=IMN_2020))+
  scale_color_continuous(low ="#7a3100", high="#e0c69b",  
                         guide = guide_legend(keyheight = unit(3, units = "mm"),
                                              keywidth=unit(12, units = "mm"), 
                                              label.position = "top", 
                                              title.position = 'top', nrow=1))+
  
  
  # Asignamos un color verde a las ANPs
  geom_sf(data=centroides_anps, color="#0E6355", size=1.5)+
  ## geom_sf(data=anps, color="#59886B")+ Con esta línea podemos ver que los 
  ## centroides de anps muy irregulares están claramente mal calculados. 
  
  labs(title="Distritaciones y área natural protegidas",
       subtitle="Pares de distritos electorales y ANPs con menor distancia",
       caption="Datos: CONANP, INE-INEGI | @sebasdepapel")+
  
  
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.background = element_rect(fill = "White", color = NA),
    legend.background = element_rect(fill = "White", color = NA),
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 12, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    
    legend.position = c(0.2, 0.09))+
  coord_sf(datum=NA)





# 3 Casos de estudio ------------------------------------------------------


## Mapas BASE

# | 3.1 Mapas Base -----------------------------------------------------------

### Cabo Pulmo
# Previsualizamos que municipios están más cercanos. (Baja California es la entidad 03)         
ggplot()+
  geom_sf(data=mgi  %>% filter(CVE_ENT %in% c("02","03")), aes(color=CVE_MUN))+
  geom_sf(data=anps %>% filter(NOMBRE=="Cabo Pulmo"), fill="green")+
  geom_sf(data=st_buffer(anps %>% filter(NOMBRE=="Cabo Pulmo"), dist = 10000))

# Filtramos a los municipios más cercanos  (003 es La Paz y 008 Los Cabos)
ggplot()+
  geom_sf(data=mgi  %>% filter(CVE_ENT=="03"& CVE_MUN %in% c("008","003")), aes(color=CVE_MUN))+
  geom_sf(data=anps %>% filter(NOMBRE=="Cabo Pulmo"), fill="green")+
  geom_sf(data=st_buffer(anps %>% filter(NOMBRE=="Cabo Pulmo"), dist = 10000), fill=NA)

###Lagunas de Chacahua
## Reptimos la exploración. Oaxaca es la entidad 20.
ggplot()+
  geom_sf(data=mgi  %>% filter(CVE_ENT=="20"))+ # Oaxaca tiene muchísimos municipios así que no será fácil inspeccionar visualmente...
  geom_sf(data=anps %>% filter(NOMBRE=="Lagunas de Chacahua"), fill="green")+
  geom_sf(data=st_buffer(anps %>% filter(NOMBRE=="Lagunas de Chacahua"), dist = 10000), fill=NA)

# Por alguna razón st_is_within_distance no funcionó correctamente.
## por facilidad utilizamos otra herramienta para obtener los municipios colindantes: Villa de Tututepec y Santiago Jamiltepec

vector_municipios=c("Villa de Tututepec", "Santiago Jamiltepec", "Santiago Tetepec", "Tataltepec de Valdés", 
  "San Miguel Panixtlahuaca", "Santa Catarina Juquila", "Santos Reyes Nopala")
  
ggplot()+
  geom_sf(data=mgi  %>% filter( CVE_ENT=="20" & NOMGEO %in% vector_municipios))+
  geom_sf(data=anps %>% filter(NOMBRE=="Lagunas de Chacahua"), fill="green")+
  geom_sf(data=st_buffer(anps %>% filter(NOMBRE=="Lagunas de Chacahua"), dist = 10000), fill=NA)


# Isla Cerralvo  (pertenece a la reserva: Islas del Golfo de California)

ggplot()+
  geom_sf(data=mgi  %>% filter(CVE_ENT%in%c("02","03","25","26")), aes(color=CVE_MUN))+
  geom_sf(data=anps %>% filter(NOMBRE=="Islas del Golfo de California"), fill="green")+
  geom_sf(data=st_buffer(anps %>% filter(NOMBRE=="Islas del Golfo de California"), dist = 10000), fill=NA)


# Debemos cortar a la isla que nos interesa. Para eso utilizaremos el mapa de los distritos cercanos
# Extraemos las coordenadas para el "bounding box"
crop=st_bbox(
  mgi  %>% filter(CVE_ENT=="03"& CVE_MUN %in% c("001","009","008","003")) #Distritos
  )

# Con base en las medidas anteriores podemos estimar algo cercano a las
## medidas para la isla cerralvo
crop<- st_bbox(c(xmin = 1700000, 
                         xmax = 1720011,
                         ymin = 1255269,
                         ymax = 1478441),
                       crs = st_crs(anps))
 
islas_recortadas <- st_crop(anps %>% filter(NOMBRE=="Islas del Golfo de California"),
                      crop)


ggplot()+
  geom_sf(data=mgi  %>% filter(CVE_ENT=="03"& CVE_MUN %in% c("001","009","008","003")), aes(color=CVE_MUN))+
  geom_sf(data=islas_recortadas, fill="green")+
  geom_sf(data=st_buffer(islas_recortadas, dist = 10000), fill=NA)+
  coord_sf()


#  | 3.2  Ingreso y Marginación... --------------

# Esta sección depende de que ejecutes las anteriores (2.2 y 3.1) Al menos,
# recuperar el vector de municipios para Lagunas y el objeto isla recortada...
vector_municipios=c("Villa de Tututepec", "Santiago Jamiltepec", "Santiago Tetepec", "Tataltepec de Valdés", 
                    "San Miguel Panixtlahuaca", "Santa Catarina Juquila", "Santos Reyes Nopala")

# Debemos cortar a la isla que nos interesa. Para eso utilizaremos el mapa de los distritos cercanos
# Extraemos las coordenadas para el "bounding box"
crop=st_bbox(
  mgi  %>% filter(CVE_ENT=="03"& CVE_MUN %in% c("001","009","008","003")) #Distritos
)

# Armamos una para replicarlo
crop<- st_bbox(c(xmin = 1203134, 
                 xmax = 1746629, 
                 ymax = 1478441, 
                 ymin = 1227511),
               crs = st_crs(anps))

islas_recortadas <- st_crop(anps %>% filter(NOMBRE=="Islas del Golfo de California"),
                            crop)



#  | 1. Cabo Pulmo y Cerralvo  -------------------------------------------------------

#png('ilustraciones/region-bc_preprocessed.png', pointsize=10, width=1800, height=1900, res=300)

##  Marginación
ggplot()+
  #Nuestros distritos y la escala (homogénea para todos los distritos)
  geom_sf(data=mgi  %>% filter(CVE_ENT %in% c("02","03")), 
          aes(fill=IM_2020), color="White", size=0)+
  scale_fill_gradient(limits=c(min(mgi$IM_2020), max(mgi$IM_2020)),
                      low ="#7a3100", high="#e0c69b",
                       guide = guide_legend(keyheight = unit(3, units = "mm"),
                                            keywidth=unit(12, units = "mm"), 
                                            label.position = "top", 
                                            title.position = 'top', nrow=1))+
   
  # Cabo Pulmo           
  geom_sf(data=anps %>% filter(NOMBRE=="Cabo Pulmo"), color= NA, fill="#217A6B")+
  geom_sf(data=st_buffer(anps %>% filter(NOMBRE=="Cabo Pulmo"),
                         dist = 10000), fill=NA, color="#217A6B",
          size=0)+
  
  # Islas Cerralvo
  geom_sf(data=islas_recortadas, color=NA, fill="#217A6B")+
  geom_sf(data=st_buffer(islas_recortadas,
                         dist = 10000), fill=NA, color="#217A6B", size=0)+
  # Otras Áreas Protegidas
    ## Agregamos el perímetro de 10km
  geom_sf(data=st_buffer(
        anps %>% 
        filter(NOMBRE!="Cabo Pulmo"  & 
               anps$REGION=="Península de Baja California y Pacífico Norte"),
                         dist = 10000), fill="#599c90", alpha=0.2, color="#599c90", size=0.2)+
  # Etiquetas

  # labs(title="Índice de marginación por región", 
  #     subtitle="Península de Baja California y Pacífico Norte",
  #     caption="Datos: CONANP, INEGI | @sebasdepapel")+
  # Tema 
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "White", color = NA),
    panel.background = element_rect(fill = "White", color = NA),
    legend.background = element_rect(fill = "White", color = NA), # Mar 88B5D7
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 10, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.43, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    
    legend.position = c(0.9, 0.9))+
  coord_sf(datum=NA)

  
  # dev.off()
  
##  Ingreso
# png('ilustraciones/region-bcingreso_preprocessed.png', pointsize=10, width=1800, height=1900, res=300)

ggplot()+
  #Nuestros distritos y la escala (homogénea para todos los distritos)
  geom_sf(data=mgi  %>% filter(CVE_ENT %in% c("02","03")), 
          aes(fill=ING_MEDIO_MUN), color="White", size=0)+
  scale_fill_gradient(limits=c(min(mgi$ING_MEDIO_MUN), max(mgi$ING_MEDIO_MUN)),
                      low ="#F0E3CD", high="#C08D36",
                      guide = guide_legend(keyheight = unit(3, units = "mm"),
                                           keywidth=unit(12, units = "mm"), 
                                           label.position = "top", 
                                           title.position = 'top', nrow=1))+
  
  # Cabo Pulmo           
  geom_sf(data=anps %>% filter(NOMBRE=="Cabo Pulmo"), color= NA, fill="#217A6B")+
  geom_sf(data=st_buffer(anps %>% filter(NOMBRE=="Cabo Pulmo"),
                         dist = 10000), fill=NA, color="#217A6B",
          size=0)+
  
  # Islas Recortadas
  geom_sf(data=islas_recortadas, color=NA, fill="#217A6B")+
  geom_sf(data=st_buffer(islas_recortadas,
                         dist = 10000), fill=NA, color="#217A6B", size=0)+
  # Otras Áreas Protegidas
  ## Agregamos el perímetro de 10km
  geom_sf(data=st_buffer(
    anps %>% 
      filter(NOMBRE!="Cabo Pulmo"  & 
               anps$REGION=="Península de Baja California y Pacífico Norte"),
    dist = 10000), fill="#599c90", alpha=0.2, color="#599c90", size=0.2)+
  # Etiquetas
  
  # labs(title="Índice de marginación por región", 
  #     subtitle="Península de Baja California y Pacífico Norte",
  #     caption="Datos: CONANP, INEGI | @sebasdepapel")+
  # Tema 
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "White", color = NA),
    panel.background = element_rect(fill = "White", color = NA),
    legend.background = element_rect(fill = "White", color = NA), # Mar 88B5D7
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 10, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.43, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    
    legend.position = c(0.9, 0.9))+
  coord_sf(datum=NA)

 # dev.off()


## A partir de aquí el codigo de las gráficas se repite
### (podrían realizarse con un forloop o una función, pero hoy me rehuso)


#  | 2. Lagunas Chacahua --------------------------------------------------

# Marginación

png('ilustraciones/region-regionitsmo_preprocessed.png', pointsize=10, width=1800, height=1900, res=300)

ggplot()+
  #Nuestros distritos y la escala (homogénea para todos los distritos)
  geom_sf(data=mgi  %>% filter( CVE_ENT %in% c("20", "07")), 
          aes(fill=IM_2020), color="White", size=0)+
  scale_fill_gradient(limits=c(min(mgi$IM_2020), max(mgi$IM_2020)),
                      low ="#7a3100", high="#e0c69b",
                      guide = guide_legend(keyheight = unit(3, units = "mm"),
                                           keywidth=unit(12, units = "mm"), 
                                           label.position = "top", 
                                           title.position = 'top', nrow=1))+
  # Lagunas de Chacahua
  geom_sf(data=anps %>% filter(NOMBRE=="Lagunas de Chacahua"), fill="#217A6B", color=NA)+
  geom_sf(data=st_buffer(anps %>% filter(NOMBRE=="Lagunas de Chacahua"),
                         dist = 10000), fill=NA, color="#217A6B", size=0)+
  # Otras áreas protegidas
  geom_sf(data=st_buffer(subset(anps, anps$REGION=="Frontera Sur, Istmo y Pacífico Sur" &
                        NOMBRE!="Lagunas de Chacahua"),
                         dist = 10000), fill="#599c90", alpha=0.2, 
                         color="#599c90", size=0.2)+
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "White", color = NA),
    panel.background = element_rect(fill = "White", color = NA),
    legend.background = element_rect(fill = "White", color = NA), # Mar 88B5D7
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 10, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.43, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    
    legend.position = c(0.1, 0.1))+
  coord_sf(datum=NA)

dev.off()

# Ingreso

png('ilustraciones/region-regionitsmo_preprocessed_ing.png', pointsize=10, width=1800, height=1900, res=300)

ggplot()+
  #Nuestros distritos y la escala (homogénea para todos los distritos)
  geom_sf(data=mgi  %>% filter( CVE_ENT %in% c("20", "07")), 
          aes(fill=ING_MEDIO_MUN), color="White", size=0)+
  scale_fill_gradient(limits=c(min(mgi$ING_MEDIO_MUN), max(mgi$ING_MEDIO_MUN)),
                      low ="#F0E3CD", high="#C08D36",
                      guide = guide_legend(keyheight = unit(3, units = "mm"),
                                           keywidth=unit(12, units = "mm"), 
                                           label.position = "top", 
                                           title.position = 'top', nrow=1))+
  # Lagunas de Chacahua
  geom_sf(data=anps %>% filter(NOMBRE=="Lagunas de Chacahua"), fill="#217A6B", color=NA)+
  geom_sf(data=st_buffer(anps %>% filter(NOMBRE=="Lagunas de Chacahua"),
                         dist = 10000), fill=NA, color="#217A6B", size=0)+
  # Otras áreas protegidas
  geom_sf(data=st_buffer(subset(anps, anps$REGION=="Frontera Sur, Istmo y Pacífico Sur" &
                                  NOMBRE!="Lagunas de Chacahua"),
                         dist = 10000), fill="#599c90", alpha=0.2, 
          color="#599c90", size=0.2)+
  theme(
    text = element_text(color = "#22211d"),
    plot.background = element_rect(fill = "White", color = NA),
    panel.background = element_rect(fill = "White", color = NA),
    legend.background = element_rect(fill = "White", color = NA), # Mar 88B5D7
    
    plot.title = element_text(size= 15, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 10, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.43, l = 2, unit = "cm")),
    plot.caption = element_text( size=10, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    
    legend.position = c(0.1, 0.1))+
  coord_sf(datum=NA)

dev.off()


# 4. Visualizaciones generales --------------------------------------------

plot(density(as.numeric(anps$ANTIGUEDAD)))
antiguedad=as.data.frame(as.numeric(anps$ANTIGUEDAD))
names(antiguedad)="tiempo"

#  | 4.1 Antiguedad y presupuesto -----------------------------------------

antiguedad %>% 
  ggplot(aes(x=tiempo)) +
  geom_density(color="#e9ecef")

# Utilizamos los datos de datos_finanzas que están en la sección 0. Procesamiento de datos.

# Tiempo desde decreto por  ANP 
# Contrario a los datos originales, tenemos datos de presupuesto hasta el 2021.
antiguedad=(as.Date("2021-01-01")-as.Date(anps$PRIM_DEC))/365
for (i in 1:183){          # Convierte antiguedad menor a cero en cero.
  if(antiguedad[i]<=0){
    antiguedad[i]=0
  }
}
anps$ANTIGUEDAD=antiguedad
# Eliminamos ANPs con antiguedad menor a cero años.
anps %>% filter(antiguedad==0) # Sierra de miguelito
anps=anps %>% filter(antiguedad!=0)

# Convertimos la superficie a kilómetros cuadrados.
anps$SUPERFICIE #Está en hectáreas (convertimos a kilómetros^2)
anps$SUPERFICIE=anps$SUPERFICIE/100

anps$S_MARINA=anps$S_MARINA/100 # Desglose para marina
anps$S_TERRES=anps$S_TERRES/100 # También para terrestre

# En un dataframe colocaremos el total de superficie para las tres categorías
t(data.frame(sum(anps$SUPERFICIE),
sum(anps$S_MARINA),
sum(anps$S_TERRES)
))

# Para restarle entonces lo que acumuló cada año desde el 2010.
(as.Date("2021-01-01")-as.Date("2010-01-01"))/365 # 11.00822 años.
años=c("2010", "2011", "2012", "2013", "2014", "2015", "2016",
       "2017", "2018", "2019", "2020")

# En cada año de antiguedad filtraremos las que eran menores
## Por ejemplo: un ANP que tiene 9 años no sumará superficie para el 2010 (11)
 
lista_tiempo=list()
for (i in 1:11){ 
    
 anps_tiempo=filter(anps, ANTIGUEDAD>=12-i) # Filtramos mayores o iguales a ant
 
 # Así, obtenemos un vector con la suma de superficie para ese entonces
 data_frame=t(data.frame(
          sum(anps_tiempo$SUPERFICIE), 
          sum(anps_tiempo$S_MARINA),
          sum(anps_tiempo$S_TERRES), 
          años[(i)])
 )
 lista_tiempo[[i]]=data_frame

}
superficie_tiempo=do.call("cbind", lista_tiempo)

# Agregando ahora los datos de finanzas
presupuesto=apply(datos_finanzas,2,sum, na.rm=TRUE)
names(datos_finanzas) # Orden de años

#Limpiamos la base de datos
row.names(superficie_tiempo)=c("SUPERFICIE", "S_MARINA", "S_TERRES", "AÑO")
colnames(superficie_tiempo)=superficie_tiempo["AÑO",]
superficie_tiempo=superficie_tiempo[1:3,]

plot(x=años, y=presupuesto/as.numeric(superficie_tiempo["SUPERFICIE",]))
# Esto es lo que queremos hacer, pero acudiré a excel por facilidad.
##### Revisar tablas-figuras.
write.csv(superficie_tiempo, "tiempo.csv")

# Loveplot Necesitamos el objeto de match-it en el código 2 :) 
loveplot=summary(m.out, standardize = T)
loveplot$sum.all[,3] #Diferencias pre-matching estandarizadas
loveplot$sum.matched[,3] #Diferencias post-matching estandarizadas

loveplot=data.frame("Nombres"=c("Propensión", "Densidad Poblacional", "Precipitación", "Elevación",
                       "Diversidad Étnica", "Int. Ecosistémica", "Pob. Residente 2015",
                       "Hombres por cada 100 mujeres","Pob. con discapacidad" ),
           "Before_PS"=loveplot$sum.all[,3], 
           "After_PS"=loveplot$sum.matched[,3])
loveplot

loveplot=loveplot%>% 
  arrange(abs(After_PS))


loveplot_graph=ggplot(loveplot) +
  # Acá agregamos los valores por balance
  geom_segment( aes(x=Nombres, xend=Nombres, y=Before_PS, yend=After_PS), color="#a9a9a9", size=0) +
  
  # Coloreamos acorde a grupo (pre/pos)
  geom_point( aes(x=Nombres, y=Before_PS), color="#C06D34", size=1) +
  geom_point( aes(x=Nombres, y=After_PS),color="#072450", size=1) +
  geom_hline(yintercept=0, color="black")+
  
  # Barras de |0.1|
  geom_hline(yintercept=0.1, color="gray", size=0, linetype=2)+
  geom_hline(yintercept=-0.1, color="gray", size=0,linetype=2)+
  
  
  theme_classic() +
  theme(
    text=element_text(family="Times", size=12, color="black"),
    panel.grid.major.x = element_blank(),
    panel.border = element_blank(),
    axis.ticks.x = element_blank()
  ) +
  coord_flip() +
  xlab("") +
  ylab("Diferencia estandarizada de medias")
 
# Almacenamos como imagen de alta resolución 
#png('D:/parques-recreacion_impacto-anps/ilustraciones/loveplot-preprocessed.png', pointsize=10, width=1500, height=800, res=300)
loveplot_graph
#dev.off()


