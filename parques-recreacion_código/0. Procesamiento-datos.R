#******************************************************************************#
#Nombre: Procesamiento de datos     
#Fecha de última actualización: 22/3/2022                              
#Proyecto: Trabajo de grado    
#Creador: Sebastián Ocampo Palacios (asesor Manuel A. Bautista-Gónzalez)
#******************************************************************************#

# 1. Librerías  -----------------------------------------------------------------------

rm (list=ls())
paquetes=c("dplyr","tidyr", "ggplot2", "sf", "lwgeom", "beepr",
           "readxl", "purrr", "openxlsx", "clubSandwich")
sapply(paquetes, 
       function (x){
         if(! x %in% rownames(installed.packages()))
           install.packages(x)
         require(x, character.only=T)
       })

# Encripción y directorio (bases de datos)
Sys.setlocale("LC_ALL", "ES_ES.UTF-8")
setwd("D:/parques-recreacion_impacto-anps/")

# 2. Bases de datos -------------------------------------------------------
mgi=st_read("datasets-brutas/shp/mun/00mun.shp")
st_crs(mgi) #Coordenate Reference System: MEXICO_ITRF_2008_LCC. Marco geoestad?stico (2021)
#ggplot(mgi)+
#  geom_sf()

anps=st_read("datasets-brutas/shp/anps/183ANP_Geo_ITRF15Diciembre_2021.shp")
st_crs(anps) #CRS: MEXICO_ITRF_2008. ?reas Naturales Protegidas (2021)
#  ggplot(anps)+
#   geom_sf()

#¿Compatibles?
st_crs(anps)==st_crs(mgi) #FALSO
#Tranformamos ambas a "Mexico ITRF2008 / LCC" con código 6372
anps=st_transform(anps,6372); mgi=st_transform(mgi, 6372);st_crs(anps)==st_crs(mgi)
# ggplot()+
#  geom_sf(data=anps)+
#  geom_sf(data=mgi)
  
#?ndice de marginaci?n
IMM <- read_excel("datasets-brutas/misc.xlsx", 
                     sheet = "IMM2020")  #?ndice_de_marginaci?n

DATOS_GEO <- read_excel("datasets-brutas/misc.xlsx", 
                  sheet = "DATOS-GEO")   #Datos geogr?ficos

FCONANP <- read_excel("datasets-brutas/misc.xlsx", 
                  sheet = "FCONANP1021", col_types = c("text", 
 "text", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", 
 "numeric", "numeric", "numeric","numeric", "numeric", "numeric", "numeric")
                  ) #Finanzas por ANP (2010-2021)
  
DEFLACTOR <- read_excel("datasets-brutas/misc.xlsx", 
                  sheet = "DEFLACTOR")

ING_MEDIO <- read_excel("datasets-brutas/misc.xlsx", 
                        sheet = "ING_MEDIO_PERSONA")

# 3. Análisis y datos geoestadísticos -------------------------------------------------
## MGI

#SUPERFICIE
SUPERFICIE=st_area(mgi)/1000000
mgi$SUPERFICIE=SUPERFICIE

## Datos sobre ANPS 
# Tiempo desde decreto por  ANP 
antiguedad=(as.Date("2020-01-01")-as.Date(anps$PRIM_DEC))/365
for (i in 1:183){          # Convierte antiguedad menor a cero en cero.
  if(antiguedad[i]<=0){
    antiguedad[i]=0
  }
}
anps$ANTIGUEDAD=antiguedad

# Eliminamos ANPs con antiguedad menor a cero años.
anps %>% filter(antiguedad==0) # Sierra de miguelito
anps=anps %>% filter(antiguedad!=0)

# SUPERFICIE por ANP
anps$SUPERFICIE #Está en hectáreas (convertimos a kilómetros^2)
anps$SUPERFICIE=anps$SUPERFICIE/100
#Presupuesto por ANP (2010-2021)

#Debemos deflactar
print(DEFLACTOR)
años=c("2010", "2011", "2012", "2013", "2014", "2015", "2016",
          "2017", "2018", "2019", "2020")


#Vamos a guardar como una matriz para deflactar r?pidamente.
datos_finanzas=FCONANP %>% select(años); storage=list()
for (i in años){
  storage[[i]]=datos_finanzas[,i]/as.numeric(DEFLACTOR[1,i])*100
}

datos_finanzas=do.call("cbind", storage)
FCONANP$PROMEDIO_REAL=apply(datos_finanzas, 1, mean, na.rm = TRUE)

#Perd?n, tendremos que cambiar el nombre de FCONANP a datos_finanzas
datos_finanzas=FCONANP %>% select(c("Dirección", "ANP", "PROMEDIO"="PROMEDIO_REAL"))

## Los nombres no encajan... necesitamos una llave.
llave_finanzas <- read_excel("datasets-brutas/misc.xlsx", 
                   sheet = "LLAVE")

llave_finanzas$`Núm-equivalencia`
datos_finanzas=datos_finanzas[llave_finanzas$`Núm-equivalencia`,]
datos_finanzas=datos_finanzas[1:182,] #Al reordenar perdemos observaciones que no nos tocaban.

datos_finanzas$anps=anps$NOMBRE #Tras inspección visual adjuntamos a datos
datos_finanzas$PROMEDIO[is.na(datos_finanzas$PROMEDIO)] = 0 #Convertimos NA en 0
anps$presupuesto=datos_finanzas$PROMEDIO

# Agregamos una dummy para identificar ecosistemas marítimos y lit.
maritima_litoral=llave_finanzas[1:182,6]
anps$maritima_litoral=maritima_litoral$Marítima
#Analizamos si se encuentra dentro de 10 km.
sf::sf_use_s2(FALSE) #Troubleshooting

# Ejemplo 
e=anps[1,]
e_2=st_is_within_distance(e,mgi, dist=10000, sparse=FALSE) #Sparse geometry binary predicate
vector=c(13,17, 18, 1905,1928)                            # 1: 13, 17, 1905, 1928. 2: 18.
df=matrix(t(sapply(e_2,c))) # Pendiente
e_3=mgi[vector,]

## Visualización
ggplot()+ 
  geom_sf(data=e_3, fill="green")+
  geom_sf(data=e)

#Intentamos realizarlo para toda la base de datos
lista_resultados=list() # En esta lista alojaremos los resultados.
## Tiempo estimado de ejecución ###
# 1-50 anps, 13 min;
# 50-100, 1 hr;
# 100-150, 1hr 23 min;
# 150-183, 1 hr 51 min. (1.71 hrs)
# Ajustar el rango (1:i) acorde al tiempo de compilación y rango de datos deseado.
start=Sys.time()
for(i in 1:0){
  iteration=anps[i,];
  iteration_result=st_is_within_distance(iteration,mgi, dist=10000, sparse=FALSE);
  matrix(sapply(iteration_result,c)) 
  lista_resultados[[i]]=iteration_result  #Almacena los resultados para la iteración "i"
}
df <- do.call("rbind",lista_resultados)
end=Sys.time()
end-start
beep()
df=as.data.frame(t(df))

# write.csv(df, "datasets-brutas/dummies-cercanas.csv")

#Al tener algunos municipios con cercanía menor a 10 km de varias áreas, 
## necesitamos conseguir datos para su anp más cercana. Trabajaremos sobre 
## el supuesto de que tiene mayor efecto (y el resto será marginal)
start=Sys.time()
supuesto_mascercanas=st_nearest_feature(st_centroid(mgi),anps) #13 seg.
end=Sys.time()
end-start
beep()
  
### rm(lista_resultados, i, start, end, df) #Limpiamos.

#Antes de continuar necesitamos trabajar la base de datos MGI


# 4. MGI: En camino a la base AGEMS ---------------------------------------
# Datos de ANP
## En excel procesamos la base de datos de la sección 3 para generar un dummy en donde
## D=1 si existen municipios a menos de 10km de un anp y 0 si no es el caso.
dummies_cercanas <- read.csv("D:/parques-recreacion_impacto-anps/datasets-brutas/dummies-cercanas.csv")
dummies_cercanas=dummies_cercanas[,2:ncol(dummies_cercanas)] #Eliminamos índice.
dummies_cercanas=apply(dummies_cercanas, 2, as.logical) # Convertimos a lógico
dummies_cercanas=apply(dummies_cercanas, 2, as.integer) # y de lógico a binario.

#Sumamos el total de condicionales por municipio (# de anps)
conteo=as.vector(apply(dummies_cercanas, 1, sum))

#Generamos una función: tomará valor 1 si la suma total (por fila) es diferente a cero.
dummies=function(x){
  if (x==0) {
    as.integer(0)
  } else {
    as.integer(1)
  }
}

vector_dummies=c() #Vector en el que almacenaremos los dummies (1=Cercanía ANPS)
for(i in 1:2471){
  d=dummies(conteo[i]); vector_dummies=append(vector_dummies,d)
}

# Ahora debemos utilizar el mgi para agregar algunos datos.
## Por facilidad *eliminaremos geometría*.
mgi=st_drop_geometry(mgi)
## DUMMIES
mgi$dummies=vector_dummies

## Nuestro supuesto de áreas más cercanas no identifica si la distancia 
## es menor a 10 km. Por eso debemos cotejar con las dummies de cercanía.
supuesto_mascercanas

for (i in 1:2471){
  if (vector_dummies[i]==0){
    supuesto_mascercanas[i]=0
  }
}

mgi$cercanas=supuesto_mascercanas

# Generamos una llave para catalogar las anps cercanas...
llave=as.data.frame(matrix(1:182, nrow=182,ncol=1, byrow=TRUE)) #Dataframe de llave
llave$NOMBRE=anps$NOMBRE
llave$CAT_MANEJO=as.factor(anps$CAT_MANEJO)
llave$SUPERFICIEANPS=anps$SUPERFICIE
llave$ANTIGUEDAD=anps$ANTIGUEDAD
llave$presupuesto=anps$presupuesto
llave$SINAP=ifelse(is.na(anps$SINAP), 0, 1) #Convierte NAs en cero y otros valores en uno.
llave$mar_litoral=as.numeric(anps$maritima_litoral)
# Generaremos un dataframe que seleccione los elementos de la llave 
## para cada ANP. Por ejemplo:
as.data.frame(llave[mgi[2,"cercanas"], 2:ncol(llave)]) #No hay ANP cercana...

df=data.frame()   #Dataframe por municipio
lista_anps=list()  #Lista de dataframes municipales.

for (i in 1:2471){
 if (mgi[i,"cercanas"]!=0){#Obtendrá datos para anps con dist<=10km (d=1)
    df= as.data.frame(llave[mgi[i,"cercanas"], 2:ncol(llave)]);
    lista_anps[[i]]=df; df=data.frame()} #Elimina los datos del df
                                         ## hasta siguiente iteración
 else{df=as.data.frame(t(c(`NOMBRE`="Ninguna", # Genera df de var. nulas si d=0 
                           `CAT_MANEJO`="Ninguna",
                           `SUPERFICIEANPS`=0,
                           `ANTIGUEDAD`=0,
                           `presupuesto`=0,
                           `SINAP`=0,
                           `mar_litoral`=0))); 
  lista_anps[[i]]=df; df=data.frame()}
}

datos_anpscercanas=do.call("rbind", lista_anps)
mgi=cbind(mgi, datos_anpscercanas)

# 5. Construcción de base: AGEMS ------------------------------------------------

# Sección derogada. Por medio del código de esta sección puedes generar el archivo 
## AGEMS.csv. No obstante, para lograrlo requerirás del archivo AGEBS ().

# Directorio
setwd("D:/parques-recreacion_impacto-anps/datasets-brutas/agebs/_conjunto_de_datos/")

# Conjunto de archivos
file_names= c(paste0("conjunto_de_datos_ageb_urbana_0", 1:9, "_cpv2020.csv"),
              paste0("conjunto_de_datos_ageb_urbana_", 10:32, "_cpv2020.csv"))



#Filtraremos solamente los datos para municipios mediante un for-loop.
lista_mun=list()
for(i in 1:32){
  df=read.csv(file_names[i], encoding = "UTF-8")%>% filter(MUN!=0 & LOC==0);
  
  #Filtramos por las variables de interés
  
  # Guardamos en una lista
  lista_mun[[i]]=df;
}

#Construimos la base de datos AGEMS con los resultados 
  AGEMS=do.call("rbind", lista_mun)
  
#Construimos la clave. La función de paste0 pegará los elementos sin dejar espacio:
CVEGEO=paste0(
 sprintf("%02d", AGEMS$X.U.FEFF.ENTIDAD), 
 sprintf("%03d", AGEMS$MUN)
); AGEMS$CVEGEO=CVEGEO  #sprintf %03: Imprime la clave del muncipio en tres díg.
                       ## PE:001, 010, 100. sprintf %02 la clave de ent. en dos.
 

#Ahora debemos comparar que las claves matcheen.
comp_1=as.numeric(CVEGEO)        #A este le faltan dos observaciones.
comp_2=as.numeric(mgi$CVEGEO)    #El MGI está desacomodado [1] 1008 1009 1010 ...            

comp_1=append(comp_1, c(50000,50000)) #Agregamos dos entradas hasta el final...
sort(comp_1)==sort(comp_2)            #Observamos que hay una entrada que rompe.
#Revisamos: encontramos que nuestra clave no incluye al municipio 02007.
comp=data.frame(sort(comp_1),sort(comp_2), sort(comp_1)==sort(comp_2))

#Incluimos al 02007.
comp_1=as.numeric(CVEGEO)
comp_1=append(comp_1, c(2007,50000)) #Aseguramos que una entrada esté al final...
sort(comp_1)==sort(comp_2)            #Observamos que hay una entrada que rompe.
#Revisamos: encontramos que nuestra clave no incluye al municipio 4013.
comp=data.frame(sort(comp_1),sort(comp_2), sort(comp_1)==sort(comp_2))

#Ahora sabemos que nos faltan los municipios 02007 y 04013 en la muestra.
comp_1=as.numeric(CVEGEO)
comp_1=append(comp_1, c(2007,4013)) 
summary(sort(comp_1)==sort(comp_2))    #2471 TRUE.       

# Homologamos.
mgi=mgi %>% arrange(CVEGEO=as.numeric(CVEGEO))
AGEMS2=AGEMS%>% arrange(CVEGEO=as.numeric(CVEGEO))

anti_join(mgi, AGEMS2) #Comprobamos que faltan San Felipe y Dzibalché (02007 y 04013)
rm(lista_mun, df, comp_1, comp_2, comp) #Limpiamos.

mgi=mgi %>% filter(CVEGEO!="04013") %>% filter(CVEGEO!="02007") #Eliminamos.

# 6. Últimos toques: AGEMS ------------------------------------------------
variables_int=c("CVEGEO", "POB_AFRO", "P5_HLI",
                "POBTOT", "REL_H_M", #Inician controles municipales
                "PRES2015", "HOGJEF_M", "PCON_DISC", "POBFEM",
                "PDER_SS", "VPH_DRENAJ", "VIVTOT", #Controles para Salud
                "GRAPROES", "PEA" #Controles por Ingresos
                )
# Seleccionamos datos de nuestro interés en el censo 2020.
data=AGEMS %>% select(variables_int)
## Tenemos tabién que transformar los datos del censo en proporciones
## Lo haremos en el análisis de datos/ visualizaciones

# Agregamos datos de anps que generamos en este código.
data=left_join(data, mgi[-4], by="CVEGEO")

#names(mgi)
#[1] "CVEGEO"         "CVE_ENT"        "CVE_MUN"        "NOMGEO"         "dummies"       
#[6] "cercanas"       "NOMBRE"         "CAT_MANEJO"     "SUPERFICIEANPS" "ANTIGUEDAD"    
#[11] "presupuesto"    "SINAP" 


filter(data, data$CVEGEO=="16108"); filter(mgi, mgi$CVEGEO=="16108") #Matchea!

# Agregamos datos geográficos a cada municipio.
## El procesamiento de esta sección surge de un proyecto de QGis.
#Eliminamos municipios sin datos.

#Antes debemos hacer que la clave sea igual
DATOS_GEO$CVEGEO==mgi$CVEGEO
DATOS_GEO$CVEGEO= as.character(sprintf("%05d", DATOS_GEO$CVEGEO))
DATOS_GEO=DATOS_GEO %>% filter(CVEGEO!="04013") %>% filter(CVEGEO!="02007") 

### DATOS_GEO=DATOS_GEO %>% select(-"SUPERFICIE")

data=right_join(data, DATOS_GEO, by="CVEGEO")

data=data %>% mutate("DENSIDADP"=POBTOT/SUPERFICIE)

#Finalmente agregamos los datos del ?ndice de marginaci?n

data=right_join(data,IMM %>% select(c("CVEGEO"="CVE_MUN","IM_2020","IMN_2020")),
                by="CVEGEO")

#Los datos de ingreso mensual medio por municipio
#para cada persona dentro una vivienda.
ING_MEDIO$CVEGEO=as.character(sprintf("%05d", ING_MEDIO$CVEGEO))
data=right_join(data,ING_MEDIO,
                by="CVEGEO")

#Guardamos base de datos.
# write.xlsx(data, "D:/parques-recreacion_impacto-anps/datos-procesados/datos.xlsx", overwrite=TRUE)
