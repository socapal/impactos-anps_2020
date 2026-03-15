#******************************************************************************#
#Nombre: Matching y muestreo     
#Fecha de última actualización: 18/3/2022                              
#Proyecto: Trabajo de grado    
#Creador: Sebastián Ocampo Palacios (asesor Manuel A. Bautista-Gónzalez)
#******************************************************************************#

# 1. Librerías  -----------------------------------------------------------------------

rm (list=ls())
paquetes=c("dplyr","tidyr", "ggplot2", "MatchIt", "sf", "lwgeom", "beepr",
           "readxl", "pastecs", "stargazer", "clubSandwich", "cobalt")
sapply(paquetes, 
       function (x){
         if(! x %in% rownames(installed.packages()))
           install.packages(x)
         require(x, character.only=T)
       })


# Encripción y directorio (bases de datos)
Sys.setlocale("LC_ALL", "ES_ES.UTF-8")
setwd("D:/parques-recreacion_impacto-anps/")

# Desactivamos la notación científica (4 decimales)
options(scipen=4)

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
                                 "numeric","numeric","numeric"))

IMM <- read_excel("datasets-brutas/misc.xlsx", 
                  sheet = "IMM2020")  #?ndice_de_marginaci?n

ING_MEDIO= read_excel("datasets-brutas/misc.xlsx", 
                      sheet = "ING_MEDIO_PERSONA")  # Ingreso medio 
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

data$SINAP

# Cambiamos dummies por "ANP_10KM".
names(data) = c("CVEGEO", "POB_AFRO", "P5_HLI", "POBTOT", "REL_H_M", "PRES2015", "HOGJEF_M",    
                "PCON_DISC", "POBFEM", "PDER_SS", "VPH_DRENAJ", "VIVTOT", "GRAPROES", "PEA", "CVE_ENT",
                "CVE_MUN", "SUPERFICIE" ,
                "ANP_10KM", #ANP_10KM == ANP_10KM
                "cercanas","NOMBRE", "CAT_MANEJO", "SUPERFICIEANPS", "ANTIGUEDAD", "presupuesto","SINAP", "mar_litoral", "P_MIN",
                "P_MAX", "ELEVACION", "INT_ECOS", "DENSIDADP", "IM_2020", "IMN_2020","ING_MEDIO_MUN", "COBERTURA",
                "div_et", "PREC_MED") #Estos últimos los crea el código.


# 4. Emparejamiento -------------------------------------------------------
#Asegurarse que no hay NA, MatchIt no corre con NA
## Debemos dejar de lado las variables que no necesitamos a?n.
matching=data 


matching=matching[complete.cases(matching), ] #2333 variables (elimina 136)
data %>% filter(dummies==0) %>% summarise(n()); 
matching %>% filter(ANP_10KM==0) %>% summarise(n())  #1,476 vs. 1394  NT
data%>% filter(dummies==1) %>% summarise(n());
matching %>% filter(ANP_10KM==1) %>% summarise(n()) #993 vs. 939      T


set.seed(1021)

binaria <- "ANP_10KM"
variables <- c("DENSIDADP", "PREC_MED", "ELEVACION", "div_et","INT_ECOS", 
               "PRES2015", "REL_H_M", "PCON_DISC")
ps <- as.formula(paste(binaria,
                       paste(variables,
                             collapse ="+"),
                       sep= " ~ "))

#Modelo más refinado
m.out <- matchit(formula=ps,
                      method = "full",
                      caliper=0.05,
                      distance = "glm", 
                      link = "probit",
                      data = matching)


summary(m.out)
        
# Revisamos el modelo (¿logit o probit?)
logit_ps = glm(ps, data = matching, family = binomial (link="logit"))
summary(logit_ps)

probit_ps=glm(ps, data = matching, family = binomial (link="probit"))
summary(probit_ps)

# Ahora guardaremos la tabla en LaTeX dentro de la carpeta datos_procesados
#Notamos que logit es ligeramente superior

stargazer(logit_ps, probit_ps, type="text") 

# la siguientes líneas almacenan este modelo en un documento .tex


## stargazer(logit_ps, probit_ps, type="latex", 
## title="Índice de propensión", digits=2, 
## dep.var.labes=c("ANPs en 10 km"),
## covariate.labels=c("Densidad poblacional", "Precipitación media anual", 
##                    "Elevación media", "Diversidad étnica", "Integridad ecosistema",
##                   "Población residente en 2015", "Relación hombres por cada 100 mujeres",
##                    "Población con discapacidad", "Constante"),
## out="datos-procesados/tablas-r/modelo_ps.tex")

# Con caliper de 0.1 perdemos 87 variables tratadas por no tener match, igualmente 542 no tratadas.
# Las observaciones que están más cerca del propensity score no encuentran.
# Cambiar a probit tambi?n disminuye las variables.

# Guardar para el second best!!!

summary(m.out, standardize = T)
bal.tab(m.out)

# plot(m.out, type = "jitter",interactive = FALSE)
plot(m.out, type = "hist")
love.plot(bal.tab(m.out), threshold = 0.1)

##QQ1
plot(m.out, type = "qq", interactive = FALSE,
     which.xs = c("DENSIDADP", "PREC_MED", "ELEVACION"))
##QQ2
plot(m.out, type = "qq", interactive = FALSE,
     which.xs = c("div_et","INT_ECOS", "PRES2015"))

##QQ3
plot(m.out, type = "qq", interactive = FALSE,
     which.xs = c("REL_H_M", "PCON_DISC"))

# Estos datos emparejan aquellas unidades con un P.S. similar.
m.data <- match.data(m.out, distance = "prop.score")

# Revisamos alternativas para nuestro modelo en la sección 6 (op)

#Ahora necesitamos adjuntar los datos que dejamos fuera para
## poder completar la regresi?n :) 
data_reg=left_join(m.data %>% select(c("CVEGEO", "prop.score", 
                                       "weights", "subclass")),
                   data, #BD completa
                   by="CVEGEO")


# Densidad
densidad=data_reg %>% 
  ggplot(aes(x=prop.score, group=ANP_10KM, fill=ANP_10KM)) +

  geom_hline(yintercept=0, color="black")+
  geom_vline(xintercept=0, color="black")+
  geom_density(fill="#072450", color="#072450",alpha=0.5)+
  
  theme_minimal() +
  theme(
    text=element_text(family="Times", size=12, color="black"),
          plot.background = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank()) +
  xlab("Índice de propensión") +
  ylab("")
densidad

# Almacenamos como imagen de alta resolución 
## png('D:/parques-recreacion_impacto-anps/ilustraciones/density-preprocessed.png', pointsize=10, width=1500, height=800, res=300)
## densidad
## dev.off()








# ¿Cuántas parejas tiene cada tratado?
summary(data_reg %>% group_by(subclass)%>% summarise(n()))


# 5. Regresiones ----------------------------------------------------------

#  A lo largo de este análisis analizamos errores agrupados 
## según las parejas, con una varianza robusta  y el test de Satterthwaite
errores_agrupados=function(model, pairing){
  coef_test(model, vcov = "CR1S",test= "Satterthwaite", 
            cluster = pairing )
}

# Así también, utilizaremos la siguiente función para
## reemplazar los errores estándar por su versión robusta-agrupada
robustsummary <- function(model, pairing) { 
  library(clubSandwich)
  coeftest <- errores_agrupados(model, pairing)
  summ <- summary(model)
  summ$coefficients[,2] <- coeftest[,3] #Reemplaza E.S.
  summ$coefficients[,3] <- coeftest[,4] #Reemplaza t-value 
  summ$coefficients[,4] <- coeftest[,6] #Reemplaza p-value
  summ
}

#  | 5.1 Índice de marginación --------------------------------------------

## Utilizando {base}
reg_slm=lm(IM_2020 ~ ANP_10KM,
           data = data_reg, weights = weights)
#Errores estándar agrupados.
coef_slm=coef_test(reg_slm_IM,
          vcov = "CR1S",
          test= "Satterthwaite",
          cluster = data_reg$subclass) 
          #equivalente a errores_agrupados(modelo)

# ¿Cómo visualizarlo?
summary(reg_slm) #Visualización simple
robustsummary(reg_slm, data_reg$subclass) #Con errores agrupados 
                       ## (no es compatible con stargazer)

stargazer(reg_slm, type="text") #Visualización útil para tablas
                                ## basada en errores no-agrupados.

#Debemos corregir las tablas que hagamos...

# Desglose por controles (4 y 5 controles)

reg_IM4=lm(IM_2020 ~ ANP_10KM + ANTIGUEDAD + SUPERFICIEANPS + 
             presupuesto + SINAP, data = data_reg, weights = weights)

reg_IM5=lm(IM_2020 ~ ANP_10KM +
             ANTIGUEDAD + SUPERFICIEANPS + 
             presupuesto + SINAP + CAT_MANEJO,
           data = data_reg, weights = weights)

stargazer(reg_slm, reg_IM4, reg_IM5,
          type="text")

#Alteraríamos los resultados de la siguiente forma
robustsummary(reg_IM5, data_reg$subclass)
rm(list=c(reg_slm,reg_IM4,reg_IM5))

# Ahora estimaremos de forma independiente cada componente.
componentes_IMM=c("ANALF", "SBASC",  
"OVSDE", "OVSEE", "OVSAE", "OVPT",
"VHAC", "PL.5000", "PO2SM")

# Agregamos los datos para las observaciones del matching...
data_reg_comp=left_join(data_reg, 
           IMM %>% select(c(CVEGEO="CVE_MUN", 
                            all_of(componentes_IMM))),
           by="CVEGEO")

# Reducimos aun df con solamente los componentes
componentes_IMM = data.frame(
  data_reg_comp %>% select(all_of(componentes_IMM)))


# Preparamos un proceso automático
coef_rsimple=data.frame()
coef_rmultiple=data.frame()
vector=c()
guia_n=as.data.frame(c("ANALF", "SBASC",  
                     "OVSDE", "OVSEE", "OVSAE", "OVPT",
                     "VHAC", "PL.5000", "PO2SM"))
guia=data.frame() # Alojará la guía

# Por construcción, los resultados se leen de abajo hacia arriba 
# (ANALF=ANP_10KM1, SBASC=ANP_10KM2, etc)


for(i in 1:9){
  
  # Extraemos los coeficientes de regresión para cada comp. en dos dataframes.
  # Regresión univariada
  reg_slm_c=lm(componentes_IMM[,i]~ ANP_10KM,
             data = data_reg, weights = weights); 
  coef_rsimple=rbind(errores_agrupados(reg_slm_c, data_reg$subclass)[2,],coef_rsimple)
  
  # Controles completos
  reg_mlm_c=lm(componentes_IMM[,i] ~ ANP_10KM +
               ANTIGUEDAD + SUPERFICIEANPS + 
               presupuesto + SINAP + CAT_MANEJO,
             data = data_reg, weights = weights); 
  coef_rmultiple=rbind(errores_agrupados(reg_mlm_c, data_reg$subclass)[2,],coef_rmultiple)
  
  # Agregamos una guía
  guia=rbind( 
    cbind(errores_agrupados(reg_slm_c, data_reg$subclass)[2,], guia_n[i,]), #Muestra el indicador
    guia)
  

}

rm(list=c("reg_mlm_c","reg_slm_c"))
  
  #  | 5.2 Ingreso, PEA y Seguro Social --------------------------------------------


# Tenemos que ajustar la clave para homologar
ING_MEDIO$CVEGEO=as.character(sprintf("%05d", ING_MEDIO$CVEGEO))

# Ingreso
data_reg=left_join(data_reg, ING_MEDIO, by="CVEGEO")

#Eliminamos municipios que no tienen representatividad muestral (2)
## Más sus variables de control :) 
filter(data_reg, COBERTURA==3) #subclass 21, 246. Mun. 04012, 07125
filter(data_reg, subclass %in% c(21,246)) # Perdemos 10 obs.

data_reg_ING=anti_join(data_reg,  #Nos quedamos con el resto.
                       filter(data_reg, subclass %in% c(21,246)))


# Regresión simple
reg_slm=lm(ING_MEDIO_MUN ~ ANP_10KM,
           data = data_reg_ING, weights = weights)

reg_ING4=lm(ING_MEDIO_MUN ~ ANP_10KM + ANTIGUEDAD +
             SUPERFICIEANPS + presupuesto + SINAP,
           data = data_reg_ING)
# Múltiple
reg_ING=lm(ING_MEDIO_MUN ~ ANP_10KM + ANTIGUEDAD +
            SUPERFICIEANPS + presupuesto + SINAP + CAT_MANEJO,
          data = data_reg_ING)

stargazer(reg_slm, reg_ING4, reg_ING, type="text")

errores_agrupados(, data_reg_ING$subclass)
robustsummary(reg_ING, data_reg_ING$subclass)



# Adscripción al seguro social
reg_ss=lm(PDER_SS ~ ANP_10KM + ANTIGUEDAD +
               SUPERFICIEANPS + presupuesto + SINAP+ CAT_MANEJO,
             data = data_reg); summary(reg_ss)

            coef_test(reg_ss,
              vcov = "CR1S",
              cluster = data_reg$subclass)

# Población económicamente activa
reg_PEA=lm(PEA ~ ANP_10KM + ANTIGUEDAD + 
             SUPERFICIEANPS + presupuesto + SINAP +  CAT_MANEJO,
           data = data_reg); summary(reg_PEA)

coef_test(reg_PEA,
          vcov = "CR1S",
          cluster = data_reg$subclass)


# 6. Refinamiento  --------------------------------------------------------


# | 6.1 Supuestos del modelo lineal --------------------------------------
modelo=reg_ref_ING # Modelo a inspeccionar

#Linearidad 
plot(modelo, 1)

# ¿Residuales normales?
plot(modelo, 2)

# Varianza homogénea en residuales
plot(modelo, 3) #la varianza no es homógenea (no hay heterodasticidad)

# Cook's distance
plot(modelo, 4)
## Para el índice de marginación, 
## observamos que hay las tres observaciones atípicas:
## 71, 205 y 1011
View(data_reg[c(71,205,1011),])

 # Residuals vs Leverage ()
plot(modelo, 5)
 

#  | 6.2 Diferenciación ANPs (marítimas-no marítimas) ---------------------

# Especificación utilizando una varaición del PS según si
## se trata de una ANP marítima.

# Marítimas
mar_lit=filter(data, mar_litoral==1 | ANP_10KM==0)
matching=mar_lit[complete.cases(mar_lit), ] # Perdemos 82 obs
set.seed(1021)

binaria <- "ANP_10KM"
variables <- c("DENSIDADP", "PREC_MED", "ELEVACION", "div_et","INT_ECOS", 
               "PRES2015", "REL_H_M", "PCON_DISC")
ps <- as.formula(paste(binaria,
                       paste(variables,
                             collapse ="+"),
                       sep= " ~ "))

#Modelo más refinado
m.out_mar <- matchit(formula=ps,
                     method = "full",
                     caliper=0.01,
                     distance = "glm", 
                     link = "probit",
                     data = matching)


summary(m.out_mar) # Hay que mejorar el balance

terrestre=filter(data, mar_litoral!=1 | ANP_10KM==0)
matching=terrestre[complete.cases(terrestre), ]
set.seed(1021)

binaria <- "ANP_10KM"
variables <- c("DENSIDADP", "PREC_MED", "ELEVACION", "div_et","INT_ECOS", 
               "PRES2015", "REL_H_M", "PCON_DISC")
ps <- as.formula(paste(binaria,
                       paste(variables,
                             collapse ="+"),
                       sep= " ~ "))

#Modelo más refinado
m.out_terrestre <- matchit(formula=ps,
                 method = "full",
                 caliper=0.05,
                 distance = "glm", 
                 link = "probit",
                 data = matching)


summary(m.out_terrestre) #Este si fue un uen modelo


#  | 6.3 Análisis de outliers ---------------------------------------------

cooksd <- cooks.distance(modelo)
# Removing Outliers
# influential row numbers (ver: Cross Validated, Removing outliers based on cook's distance in R Language)
# !!! ES IMPORTANTE SUSTITUIR EL DATASET QUE ESTÁS ANALIZANDO 
dataset=data_reg_ING

influential <- as.numeric(names(cooksd)[(cooksd > (4/nrow(dataset)))])

#Debemos eliminar sus parejas.
llave=dataset[influential,"subclass"]
llave$subclass

# Con esta especificación perdemos 480 variables :9
outliers=dataset %>% filter(subclass %in%  llave$subclass)

data_reg_ref=anti_join(dataset, outliers)

reg_ref=lm(ING_MEDIO_MUN ~ ANP_10KM +
             ANTIGUEDAD + SUPERFICIEANPS + 
             presupuesto + SINAP + CAT_MANEJO,
           data = data_reg_ref, weights = weights)

# Revisamos errores agrupados.
errores_agrupados(reg_ref,data_reg_ref$subclass)

stargazer(reg_slm, reg_ING4, reg_ING, reg_ref,
          type="text")


robustsummary(reg_ref, data_reg_ref$subclass)


# 7. Refinamiento: Métodos matching ---------------------------------------------------------
## Compareremos al final con una tabla.

# No NAs
matching=matching[complete.cases(matching), ] #2333 variables (elimina 136)

# |  7.1.1 One Neighbour (ON) --------------------------------------------------------

m.out_nearest=matchit(formula=ps,
                method = "nearest",
                ratio = 1,
                distance= "glm",
                link = "probit", #Cambiar de logit a probit ofrece una mejora...
                replace = FALSE,
                data = matching)

bal.tab(m.out_nearest) # Observamos que la diferencia de ajuste es de 0.3 para el ps.


# |  7.1.2 ON (w/replacement)  --------------------------------------------------------

m.out_nearestwr=matchit(formula=ps,
                      method = "nearest",
                      ratio=1,
                      distance= "glm",
                      link = "probit", #Cambiar a probit  también mejora...
                      replace = TRUE,
                      data = matching)

bal.tab(m.out_nearestwr) # Observamos que la diferencia de ajuste es de 0.3 para el ps.


# | 7.1.3 ON (Caliper) --------------------------------------------

m.out_caliper=matchit(formula=ps,
                        method = "nearest",
                        caliper=0.01,
                        ratio=1,
                        distance= "glm",
                        link = "probit",
                        data = matching)

bal.tab(m.out_caliper) # nálogo


# | 7.2 Vecinos múltiples (wr) ---------------------------------------------------
# Para este punto establecemos replacement (mejora resultados) y fijamos probit.
## Intentamos obtener resultados para 1, 2, 3 y 5 vecinos cercanos. Parece que el 
## segundo mejor es 2 (pero hay que confirmarlo).
m.out_nearest_two=matchit(formula=ps,
                      method = "nearest",
                      ratio = 2,
                      distance= "glm",
                      link = "probit",
                      replace = TRUE,
                      data = matching)

bal.tab(m.out_nearest) # Observamos que la diferencia de ajuste es de 0.3 para el ps.

# | 7.3 Full matching  ------------------------------------------------------
require("optmatch")

# Emparejamiento de muestra completa :) 
m.out_full <- matchit(formula=ps,
                      method = "full",
                      caliper=0.05,
                      distance = "glm", 
                      link = "probit",
                      data = matching)

bal.tab(m.out_full, data=matching)
  # En comparación con el matching de un único 


#  | 7.4 Genetic Matching -------------------------------------------------

# Requiere de una función para el paquete rgneoud. La instalación
## está abajo

#if (!require("devtools")) install.packages("devtools")
#devtools::install_github("JasjeetSekhon/rgenoud")

# El método genético tiene un tamaño de población definido de 100 personas.
## Por esto, es importante que lo modifiquemos. Eso sí, el proceso es lento y 
## realizarlo puede ser más tardado al extender el pop.size. Revisar 
## el tiempo de de ejecución con una pob. de 100 para considerar incrementarlo.
## Utilizamos cuatro núcleos para facilitar el procesamiento. 
## En mi caso son 35 minutos para cuatro núcleos y 1000 observaciones.
start=Sys.time()
m.out_genetic <- matchit(formula=ps,
                      method = "genetic",
                      distance = "glm", 
                      link = "probit",
                      estimand = "ATT",
                      discard = "none",
                      data = matching,
                      pop.size=1000,
                      cluster = c("localhost",
                                  "localhost", "localhost", "localhost"))
Sys.time()-start #Tiempo de ejecución.
beep()
bal.tab(m.out_genetic, data=matching)

# saveRDS(m.out_genetic, "datos-procesados/m.out_genetic.RData")


#  | 7.5 Regresiones de comparación ----------------------------------------------

# Nuestra lista de variantes en emparejamiento
match_variants=as.list(c("m.out_nearest", "m.out_nearestwr", "m.out_caliper",
  "m.out_nearest_two","m.out_full","m.out_genetic"))

# Lista en la que almacenaremos resultados simples
reg_results=list(c())
# Lista en la que almacenaremos resultados con características 
regm_results=list(c())
# Lista en la que almacenamos tablas de balance
bal.tab_results=list(c())
###

##No pude automatizar el proceso... Simplemente falta hacer que el for pueda
## obtener los objetos matchit (por ejemplo m.out) para que le algoritmo sirva.
## No obstante, con tan solo hacer el remplazo de cada método en el algoritmo
## siguiente, así como de sus índices (m.out_nearest=1) podemos obtener la
## tabla



# for (i in 1:length(match_variants)){
  
  # Analizamos la regresión simple para cada modelo.

      # Primero generamos los datos 
      m.data <- match.data(m.out_genetic, distance = "distance")
      
      bal.tab_results[[6]]=bal.tab(m.out_genetic, data=matching)
      
      data_reg=left_join(m.data %>% select(c("CVEGEO", "distance", 
                                         "weights", "subclass",
                                         "ANP_10KM")),
                     data, #BD completa
                     by="CVEGEO")
      
      # Realizamos la regresión simple (utilizamos {base})
      reg_slm=lm(IM_2020 ~ ANP_10KM,
                 data = data_reg, weights = weights); 
      summary(reg_slm)
      
        # Errores estándar agrupados.
      reg_results[[6]]=coef_test(reg_slm,
                        vcov = "CR1S",
                        cluster = data_reg$subclass)
      
      # Regresión con características de ANPs
      reg_mlm=lm(IM_2020 ~ ANP_10KM +
                   ANTIGUEDAD + SUPERFICIEANPS + 
                   presupuesto + SINAP + as.factor(CAT_MANEJO),
                 data = data_reg, weights = weights); 
      summary(reg_mlm)
      
        # Errores estándar agrupados.
      regm_results[[6]]=coef_test(reg_mlm,
                         vcov = "CR1S",
                         cluster = data_reg$subclass)
      
# Podemos almacenar los resultados acá:
      #capture.output(bal.tab_results[[6]], 
      #file="datos-procesados/tablas-r/test_bal.txt", append = TRUE)
      #capture.output(reg_results[[6]], 
      #              file="datos-procesados/tablas-r/test_reg.txt", append = TRUE)
      #capture.output(regm_results[[6]], 
      #              file="datos-procesados/tablas-r/test_regm.txt", append = TRUE)

      #}
      
      
# Falta especificar diferentes tipos de error...

