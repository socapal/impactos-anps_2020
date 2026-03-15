#******************************************************************************#
#Nombre: Estadística descriptiva y tablas.     
#Fecha de última actualización: 18/3/2022                              
#Proyecto: Trabajo de grado    
#Creador: Sebastián Ocampo Palacios (asesor Manuel A. Bautista-Gónzalez)
#******************************************************************************#

# 1. Librerías  -----------------------------------------------------------------------

rm (list=ls())
paquetes=c("dplyr","tidyr", "ggplot2",  "sf", 
           "readxl", "pastecs", "modelsummary")
sapply(paquetes, 
       function (x){
         if(! x %in% rownames(installed.packages()))
           install.packages(x)
         require(x, character.only=T)
       })


# Encripción y directorio (bases de datos)
Sys.setlocale("LC_ALL", "ES_ES.UTF-8")
setwd("D:/parques-recreacion_impacto-anps/")
# setwd("E:/parques-recreacion_impacto-anps/")

# 2. Bases de datos: AGEMS ------------------------------------------------
library(readxl)
data <- read_excel("datos-procesados/datos.xlsx", 
                    col_types = c("text", "numeric", "numeric", 
                                  "numeric", "numeric", "numeric", 
                                  "numeric", "numeric", "numeric", 
                                  "numeric", "numeric", "numeric", 
                                  "numeric", "numeric", "text", "text", 
                                  "numeric", "numeric", "text", "text", 
                                  "text", "numeric", "numeric", 
                                  "numeric", "numeric", "numeric", 
                                  "numeric", "numeric", "numeric", 
                                  "numeric", "numeric", "numeric",
                                  "numeric", "numeric", "numeric"))

IMM <- read_excel("datasets-brutas/misc.xlsx", 
                  sheet = "IMM2020")  #?ndice_de_marginaci?n

# 3. Conversión de datos --------------------------------------------------

#Datos municipales
#Convertimos datos en proporciones respecto del total

### Proporciones 
Poblacionales= c("POB_AFRO", "P5_HLI","PCON_DISC","PRES2015",
                 "PDER_SS", #Controles para Salud
                 "GRAPROES", "PEA") #Controles por Ingresos

data$POB_AFRO=data$POB_AFRO/data$POBTOT*100
data$P5_HLI=data$P5_HLI/data$POBTOT*100
data$PCON_DISC=data$PCON_DISC/data$POBTOT*100
data$POBFEM=data$POBFEM/data$POBTOT*100
data$PDER_SS=data$PDER_SS/data$POBTOT*100
data$PEA= as.numeric(data$PEA); data$PEA=data$PEA/data$POBTOT*100
data$PRES2015=as.numeric(data$PRES2015)/as.numeric(data$POBTOT)*100

# Factores de escala

## Densidad poblacional
data=data %>% mutate("DENSIDADP"=POBTOT/SUPERFICIE)
## vivienda 
data$VPH_DRENAJ=data$VPH_DRENAJ/data$VIVTOT*100
## Integridad ecosistémica 
data$INT_ECOS=data$INT_ECOS*100
## Índice de Diversidad Étnica (Baqir et al.)
div_et=(10000-(data$POB_AFRO)^2-(data$P5_HLI)^2)/100 #Revisar, no me convence.
data$div_et=div_et
# Precipitación media
data=data  %>%  mutate(PREC_MED=(data$P_MAX+data$P_MIN)/2)
# Categor?as como factores
data$CAT_MANEJO=as.factor(data$CAT_MANEJO)
#Presupuesto (en miles)
data$presupuesto=data$presupuesto/1000


## Estadística descriptiva
stat.desc(data, basic=FALSE, desc=TRUE)

# Pruebas T.
## Realizamos pruebas T para nuestras principales variables de interés
c("IM_2020", "INT_ECOS", "PREC_MED", "ELEVACION",
  "div_et","DENSIDADP", "PRES_2015", 
  "REL_H_M", "PCON_DISC")

t.test(data=filter(data, COBERTURA!=3),
       ING_MEDIO_MUN ~ dummies)

stargazer(lm(data=data,
   presupuesto ~ dummies), type="text")

datasummary_balance(~dummies,
                    fmt = "%.2f",
                    data = filter(data, COBERTURA!=3),
                    title = "Pruebas de balance",
                    notes = "Fuente: Sebastián Ocampo")

#Tablas de balance según categoría
lista=list(c())
for (i in 1:7){
lista[[i]]=datasummary_balance(~dummies,
                    fmt = "%.2f",
                    data = filter(data, COBERTURA!=3 & 
                           CAT_MANEJO==levels(data$CAT_MANEJO)[i]),
                    title = "Pruebas de balance",
                    notes = "Fuente: Sebastián Ocampo",
                    output="data.frame")[1:30,]
}

# 4. Estadística descriptiva --------------------------------------------

# Ya que tenemos la base de datos y otros insumos, debemos generar la versi?n final
## entre tratadas y no tratadas. Para lograr esto acudimos a los datos censales de AGEMs
head(data)
no_tratadas= data %>% filter(dummies==0) # 1476
tratadas=data %>% filter(dummies==1)    # 993

sdt=stat.desc(tratadas, basic=FALSE, desc=TRUE); sdt
sdnt=stat.desc(no_tratadas, basic=FALSE, desc=TRUE); sdnt

# Este cuadro obtiene las diferencias en medias, primero al obtener los datos
## de media y varianza para cada cuadro de estadística descriptiva (sdt,sdnt)
## Los junta y reagrupa como un dataframe (transpuesto).

est_desct=t(cbind(as.data.frame(t(sdt)) %>% select( c(mean_t="mean", var_t="var")),
as.data.frame(t(sdnt)) %>% select( c("mean", "var"))
));est_desct=as.data.frame(
  t(as.data.frame(est_desct) %>% 
    select(-c("CVEGEO", "CVE_ENT", "CVE_MUN", "dummies", "cercanas"))
  )
); est_desct

data %>% group_by(dummies) %>% summarize(mean = mean(members_resid_bl), 
                                         std = sd(members_resid_bl), n = n()) %>% ungroup()


# write.xlsx(est_desct, "D:/parques-recreacion_impacto-anps/datos-procesados/tbdesc.xlsx", overwrite=TRUE)

rm(est_desct,sdt,sdnt,div_et, no_tratadas, tratadas)
  
# 5. ANPs  ------------------------------------------
## Permite ver estad?stica descriptiva sobre las ANPs
#El objeto de ANPS viene del c?digo anterior (Sec 3. L?neas 63-116)
#Algunos datos sobre ANPS
anps=st_drop_geometry(anps)

# Tabla ANP_A
#Extensión total, presupuesto y observaciones por categoría
s=anps %>% group_by(CAT_MANEJO) %>% 
  summarize( Presupuesto_medio = mean(presupuesto), 
             Superficie_total=sum(SUPERFICIE),   #km^2
             `$/KM^2`=sum(presupuesto)/sum(SUPERFICIE),
             ANPs=n()) 

#Áreas dentro del por SINAP categoría
anps %>% group_by(CAT_MANEJO) %>% count(SINAP)

# Tabla ANP_B
anps %>% group_by(REGION) %>% 
  summarize( Presupuesto_medio = mean(presupuesto, na.rm=TRUE), 
             Superficie_total=sum(SUPERFICIE),   #h?ctareas
             `$/HA`=mean(presupuesto, na.rm=TRUE)/sum(SUPERFICIE),
             ANPs=n())

anps %>% group_by(REGION) %>% count(SINAP)

# Tabla ANP_C Medias y Varianzas 
anps %>% 
  summarise(mean(presupuesto), var(presupuesto), n())

# Esto es medio interesante. Muestra cambios en políticas 
plot(density(as.numeric(anps$ANTIGUEDAD)))

# Datos de figura 1.
#Ejecutando la sección de prespuesto finanzas en el código de procesamiento de datos (0.)
## Podemos obtener los datos financieros para cada ANPs. En este caso, es importante
## ejecutar la siguiente línea en lugar de la línea 101
datos_finanzas=FCONANP
# En lugar de  "tendremos que cambiar el nombre de FCONANP a datos_finanzas"
#101 | datos_finanzas=FCONANP %>% select(c("Dirección", "ANP", "PROMEDIO"="PROMEDIO_REAL"))

## Luego, ejecutamos la siguiente línea (al llegar hasta el final de la sección o la línea 115)
datos_finanzas$REGION=anps$REGION

vars=c("2010", "2011", "2012", "2013", "2014", "2015", "2016",
       "2017", "2018", "2019", "2020")

# Por Región
datos_finanzas %>% 
  group_by(REGION) %>% 
  summarise_at(vars(vars), mean, na.rm=TRUE)

# Por Manejo
datos_finanzas %>% 
  group_by(CAT_MANEJO) %>% 
  summarise_at(vars(vars), mean, na.rm=TRUE), "presupuesto-cat.csv"




