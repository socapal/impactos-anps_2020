#******************************************************************************#
#Nombre: Procesamiento de datos (no incluir)     
#Fecha de última actualización: 08/05/2022)                             
#Proyecto: Trabajo de grado    
#Creador: Sebastián Ocampo Palacios (asesor Manuel A. Bautista-Gónzalez)
#******************************************************************************#

# Paquetes
require(dplyr)
require(tidyr)

# 1. Datos geográficos  -----------------------------------------------------------------------

elevacion <- read.csv("C:/Users/socap/Downloads/Conjunto de datos geograficos/Elevacion/elevacion.csv", 
                      encoding="UTF-8")
precipitacion <- read.csv("C:/Users/socap/Downloads/Conjunto de datos geograficos/Precipitacion/intento.csv", 
                    encoding="UTF-8")
ecosistema <- read.csv("C:/Users/socap/Downloads/Conjunto de datos geograficos/Ecosistema/ecosistema.csv", 
                       encoding="UTF-8")

# Procesamos datos de precipitacion
precipitacion=as_tibble(precipitacion)
head(precipitacion)
precipitacion=precipitacion %>% separate(PANUAL, c("MIN", "MAX"))
precipitacion$MIN=as.numeric(precipitacion$MIN) ; precipitacion$MAX=as.numeric(precipitacion$MAX)

df_sup_total=precipitacion %>% 
  group_by(CVEGEO) %>% 
  summarise(sup_total = sum(superficie))

precipitacion=left_join(precipitacion, df_sup_total, by="CVEGEO")

precipitacion=precipitacion %>% 
  group_by(CVEGEO) %>%  
  mutate(WMIN=sum(superficie/sup_total*MIN),
         WMAX=sum(superficie/sup_total*MAX))

precipitacion_agregada=precipitacion %>% 
  group_by(CVEGEO)  %>%  summarise(P_MIN=round(mean(WMIN), digits=-1),
                                   P_MAX=round(mean(WMAX), digits=-1))

#Agregamos los datos de precipitacion y elevacion.
datos_geo=left_join(precipitacion_agregada, elevacion  %>% select(c(ELEVACION=X_mean, CVEGEO)),
          by="CVEGEO"
          )

datos_geo= datos_geo  %>% mutate(ELEVACION=round(ELEVACION, digits=0)) #redondeamos elevaci?n.

#Agregamos datos de integridad del ecosistema
datos_geo=left_join(datos_geo, ecosistema  %>% select(c(INT_ECOS=X_mean, CVEGEO)),
                    by="CVEGEO"
)


datos_geo$CVEGEO= as.character(sprintf("%05d", datos_geo$CVEGEO))

# Almacenar?amos as? (ya est? almacenada en misc):
# write.csv(datos_geo,"D:/parques-recreacion_impacto-anps/datasets-brutas/DATOS-GEO.csv")

# 2. Ingreso medio por municipio -------------------------------------------------

#install.packages("bigmemory")
require(bigmemory)
require(readr)
require(dplyr)

# Check memory limit
memory.limit()
# Change memory limit
memory.limit(size = 15000)


CPV_I=read_csv(file="C:/Users/socap/Downloads/Personas00.csv", n_max=10)
col_vector=names(CPV_I)

CPV_IM=read.big.matrix("C:/Users/socap/Downloads/Personas00.csv", sep = ",", col.names = col_vector)
CPV_IM %>% select(c("ENT","MUN","ID_VIV","ID_PERSONA","COBERTURA","ESTRATO","UPM",
                  "FACTOR", "EDAD", "INGTRMEN"))
col_vector


names(CPV_I) #Nos interesa del 1 al 9, el 13 y el 71
vector=c(1,2,3,4,5,6,7,8,9,13,71)
CPV_INDICADORES=CPV_IM[,vector]
head(CPV_INDICADORES)


# saveRDS(CPV_INDICADORES, "AYUDA.RData")

CPV_INDICADORES=as_tibble(CPV_INDICADORES)

CVEGEO=paste0(
  sprintf("%02d", CPV_INDICADORES$ENT), 
  sprintf("%03d", CPV_INDICADORES$MUN)
); CPV_INDICADORES$CVEGEO=CVEGEO

# Obtenemos el ingreso por mensual por persona por vivienda para cada municipio
ING_MEDIO=CPV_INDICADORES  %>%
  group_by(ID_VIV) %>%
  summarise(
    ING=sum(INGTRMEN,na.rm=TRUE), N=n(),FACTOR, #Ingreso, tamaño de casa + variables
    CVEGEO, COBERTURA) %>% 
  group_by(CVEGEO) %>%
  summarise( 
    weighted.mean(ING/N, FACTOR, na.rm=TRUE)    #Utilizamos var (CVEGEO y FACTOR)
                                               ## Para un promedio ponderado.
  )

COB=CPV_INDICADORES %>% group_by(CVEGEO) %>% summarise(mean(COBERTURA))
head(S)

cob=cbind(COB, ING_MEDIO)[,2:4]


  write.csv(cob,"C:/Users/socap/Downloads/ING_MEDIO_PERSONA.csv")
