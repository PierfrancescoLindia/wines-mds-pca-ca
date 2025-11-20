# Laboratorio di Metodi Statistici per le Strategie Aziendali

# 1° Assignment (19/11/2025)

# Gruppo di lavoro: Cristian Tedesco, Francesco De Nisi, Angela Karin Mancuso, Nabil Larhram,
# Saveria Falvo, Pierfrancesco Lindia.

#===========================================================
# INDICE DELLO SCRIPT
#===========================================================
# 1. Pacchetti utilizzati
# 2. Caricamento e ispezione del dataset
# 3. Analisi esplorativa
#    3.1 Statistiche descrittive generali
#    3.2 Statistiche per singola classe
# 4. Multi-Dimensional Scaling (MDS metrico)
#    4.1 Calcolo dei centroidi per classe
#    4.2 Distanze, autovalori e GoF
#    4.3 Scree plot MDS
#    4.4 Mappa percettiva MDS
# 5. ANOVA per confronto tra classi
# 6. Analisi delle Componenti Principali (PCA)
#    6.1 PCA sui centroidi
#    6.2 Biplot e loadings
# 7. Confronto MDS vs. PCA
#    7.1 Coordinate e varianza spiegata
#    7.2 Mappa percettiva di confronto
# 8. Analisi delle Corrispondenze (CA)
#    8.1 Tabella di contingenza preferenze × classi
#    8.2 CA: mappe dei profili e contributi
#===========================================================


#-----------------------------------------------------------
# 1. Pacchetti utilizzati
#-----------------------------------------------------------

library(ggplot2)
library(tidyr)
library(dplyr)
library(tibble)
library(knitr)
library(kableExtra)
library(tidyverse)
library(corrplot)
library(factoextra)
library(ca)


#-----------------------------------------------------------
# 2. Caricamento e ispezione del dataset
#-----------------------------------------------------------

# Caricamento dei dati
dati <- read.table("wines2.txt", header = TRUE)

# Ispezione dei dati
head(dati)
str(dati)
colSums(is.na(dati))

# Selezione delle Classi di vini
classi <- dati$Classificazione
#numerosità delle classi
summary(as.factor(classi))

# Selezione delle colonne 2-14 per composizione
composizione <- dati[, 2:14]

# Statistiche descrittive di composizione
summary(composizione)


# Controllo per classi
for (i in 1:5) {
  cat("\n============================\n")
  cat("Classificazione =", i, "\n")
  cat("============================\n")
  
  print(summary(dati[dati$Classificazione == i, 2:14]))
}



# ISTOGRAMMA VARIABILE CLASSIFICANZIONE:


ggplot(dati, aes(x = factor(Classificazione))) +
  geom_bar(fill = "skyblue") +
  labs(title = "Distribuzione delle classi di vino",
       x = "Classificazione", y = "Frequenza") +
  theme_minimal()


#-----------------------------------------------------------
# 3. Analisi esplorativa
#-----------------------------------------------------------

# Distribuzione delle variabili 2:14

# 1. Definizione delle variabili
variabili_pt1 <- c("Alcohol", "Malic.acid", "Ash", "Alcalinity.of.ash", "Magnesium",
                   "Total.phenols", "Flavanoids", "Nonflavanoid.phenols", "Proanthocyanins")

variabili_pt2 <- c("Color.intensity", "Hue", "OD280.OD315.of.diluted.wines", "Proline",
                   "F", "M", "Eta18_25", "Eta25.40", "Eta_sup40")

dati_long1 <- dati %>%
  pivot_longer(cols = all_of(variabili_pt1), names_to = "Variabile", values_to = "Valore")


dati_long2 <- dati %>%
  pivot_longer(cols = all_of(variabili_pt2), names_to = "Variabile", values_to = "Valore")


# 2. Creazione GRAFICO 1 (Griglia 3x3)
plot1 <- dati_long1 %>%
  filter(Variabile %in% variabili_pt1) %>%
  
  mutate(Variabile = factor(Variabile, levels = variabili_pt1)) %>%
  
  ggplot(aes(x = Valore)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~ Variabile, scales = "free", ncol = 3) +
  theme_minimal() +
  labs(title = "Distribuzione delle Variabili (Parte 1)",
       x = "Valore", y = "Frequenza")

# 3. Creazione GRAFICO 2 (Griglia 3x3)
plot2 <- dati_long2 %>%
  filter(Variabile %in% variabili_pt2) %>%
  mutate(Variabile = factor(Variabile, levels = variabili_pt2)) %>%
  
  ggplot(aes(x = Valore)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~ Variabile, scales = "free", ncol = 3) +
  theme_minimal() +
  labs(title = "Distribuzione delle Variabili (Parte 2)",
       x = "Valore", y = "Frequenza")

print(plot1)
print(plot2)

#-----------------------------------------------------------
# 4. Multi-Dimensional Scaling (MDS metrico)
#-----------------------------------------------------------


# --- Preparazine dataset per MDS ---


# *** Aggregazione dei dati per classi e calcolo dei centrodi ***

# 1. Calcolo della media di ogni colonna (da 2 a 14) per ogni classe (colonna 1)
centroidi <- aggregate(composizione, by = list(classi), FUN = mean)

# 2. Impostazione dei nomi delle righe per una facile identificazione nel grafico
rownames(centroidi) <- paste("Classe", centroidi$Group.1)

# 3. Standardizzazione delle variabili (centroidi)
centroidi_scaled <- scale(centroidi[, -1])

# 4. Calcolo della matrice di dissimilarità (distanza Euclidea)

# Creazione di una matrice 5x5 di distanze tra le classi
dist_matrix <- dist(centroidi_scaled)

print("Matrice di Dissimilarità tra le Classi:")
print(dist_matrix)

# --- MDS metrico sui centroidi delle classi di vino ---


# Esecuzione di MDS Metrico in 2 dimensioni (k=2)
(mds_fit <- cmdscale(dist_matrix, k = 2, eig = TRUE))


# Visualizzazione degli autovalori delle prime due componenti
mds_fit$eig

# Visualizzazione della bontà di adattamento
mds_fit$GOF

# Estrazione delle coordinate 2D
(coord <- mds_fit$points)

# Calcolo della matrice Q
(Q<-coord%*%t(coord))

# --- Scree plot per MDS (cmdscale) ---

# Impostazione del numero massimo di dimensioni possibili (n-1)
kmax <- nrow(centroidi_scaled) - 1

# Esecuzione di MDS a dimensionalità massima per ottenere tutti gli autovalori
mds_full <- cmdscale(dist_matrix, k = kmax, eig = TRUE)

# Autovalori
(eig <- mds_full$eig)

# Considerazione della parte positiva per la quota di varianza spiegata
eig_pos <- pmax(eig, 0)

# Varianza spiegata per dimensione
(var_exp <- eig_pos / sum(eig_pos))

# Varianza cumulata
(cum_var <- cumsum(var_exp))

# Scree plot degli autovalori
plot(seq_along(eig_pos), eig_pos, type = "b", pch = 19,
     xlab = "Dimensione", ylab = "Autovalore",
     main = "Scree plot autovalori (Classical MDS)",
     col="lightblue")


# MAPPA PERCETTIVA MDS METRICO SUI CENTROIDI DELLE CLASSI DI VINI


plot(coord[, 1], coord[, 2], type = "n", asp = 1,
     main = "MDS Metrico delle Classi di Vino (basato sulla Composizione)",
     xlab = "Dimensione 1",
     ylab = "Dimensione 2")

# Aggiunta delle etichette per ogni classe
text(coord[, 1], coord[, 2], labels = rownames(centroidi), col = "blue")
abline(v=0,h=0)

# Calcolo della bontà di adattamento
gof <- (mds_fit$eig[1] + mds_fit$eig[2]) / sum(mds_fit$eig[mds_fit$eig > 0])
print(paste("Bontà di Adattamento (GoF) per 2D:", round(gof, 3)))

# ----------------------------------------------------------
# 5. ANOVA per confronto tra classi
# ----------------------------------------------------------

# Conversione di 'Classificazione' in un fattore
dati$Classificazione <- as.factor(dati$Classificazione)

nomi_variabili <- colnames(dati)[2:14]

# Esecuzione di un ciclo che calcola l'ANOVA per ogni variabile


lista_risultati_aov <- list()

for (variabile in nomi_variabili) {
  formula_aov <- as.formula(paste(variabile, "~ Classificazione"))
  modello_aov <- aov(formula_aov, data = dati)
  cat("\n=============================================\n")
  cat(" Risultati ANOVA per:", variabile, "\n")
  cat("=============================================\n")
  print(summary(modello_aov))
  lista_risultati_aov[[variabile]] <- summary(modello_aov)
}

# Riepilogo dei p-value
for (variabile in nomi_variabili) {
  p_value <- lista_risultati_aov[[variabile]][[1]]$`Pr(>F)`[1]
  cat(sprintf("%-30s p-value: %s\n", variabile, format.pval(p_value, digits = 2, eps = 0.001)))
}



#-----------------------------------------------------------
# 6. Analisi delle Componenti Principali (PCA/ACP)
#-----------------------------------------------------------

# 1. Esecuzione ACP
pca_fit <- prcomp(centroidi_scaled)

# 2. Controllo della Varianza Spiegata
print("Riepilogo della Varianza Spiegata (PCA):")
summary(pca_fit)

# 3. Creazione del Biplot
fviz_pca_biplot(pca_fit,
                geom.ind = c("point", "text"),
                repel = TRUE,
                pointsize = 4,
                col.ind = "blue",
                col.var = "orchid",
                alpha.var = 0.7,
                title = "Biplot PCA dei Centroidi delle Classi",
                legend.title = "Gruppi"
)

# 4. Esaminazione dei loadings
print("Loadings (Contributo delle variabili agli assi):")
print(pca_fit$rotation)



#-------------------------------------------------------
# 7. Confronto MDS vs. PCA
#-------------------------------------------------------

cat("Coordinate dei punti ottenute mediante MDS metrico")
coord
cat("Coordinate dei punti ottenute mediante PCA")
(coord_pca <- pca_fit$x[, 1:2])

# Calcolo varianza cumulata ACP
var_cumulata <- summary(pca_fit)$importance["Cumulative Proportion", ]
print(var_cumulata[2])

# Bontà di adattamento MDS
print(paste("Bontà di Adattamento (GoF) per 2D:", round(gof, 3)))

# Verifica che sia uguale a GOF
(test <- var_cumulata["PC2"] == round(gof, 5))

# Mappa percettiva di confronto

plot(coord_pca[, 1], coord_pca[, 2],
     xlim = range(c(coord_pca[,1], coord[,1])) * 1.1,
     ylim = range(c(coord_pca[,2], coord[,2])) * 1.1,
     type = "n", asp = 1,
     main = "Confronto tra PCA e MDS",
     xlab = "Dimensione 1",
     ylab = "Dimensione 2")

# griglia
grid(col = "lightgray", lty = "dotted")

# Linee che collegano PCA <-> MDS per ogni osservazione
segments(coord_pca[,1], coord_pca[,2],
         coord[,1], coord[,2],
         col = rgb(0.5, 0.5, 0.5, 0.5))

# Punti PCA
points(coord_pca[,1], coord_pca[,2],
       col = rgb(1, 0, 0, 0.7), pch = 19, cex = 1.2)

# Punti MDS
points(coord[,1], coord[,2],
       col = rgb(0, 0, 0, 0.7), pch = 17, cex = 1.2)

# Assi
abline(v = 0, h = 0, col = "gray40", lty = 2)

# Legenda
legend("topright",
       legend = c("PCA", "MDS", "Differenza"),
       col = c("red", "black", "gray"),
       pch = c(19, 17, NA),
       lty = c(NA, NA, 1),
       bty = "n")


#--------------------------------------------------------
# 8. Analisi delle Corrispondenze (CA)
#--------------------------------------------------------

# Creazione della Tabella di Contingenza 
# Selezione delle colonne che servono: Classificazione (1) e Preferenze (15-19)
dati_preferenze <- dati[, c(1, 15:19)]

# Aggregazione dei dati: calcolo della somma delle preferenze per ogni gruppo, raggruppando per "Classificazione"
tabella_contingenza <- aggregate(. ~ Classificazione, data = dati_preferenze, FUN = sum)

# Trasformazione della colonna "Classificazione" in nomi di riga.
rownames(tabella_contingenza) <- paste("Classe", tabella_contingenza$Classificazione)

# Rimozione della colonna "Classificazione" 
tabella_contingenza <- tabella_contingenza[, -1]

# Visualizzazione della tabella di contingenza creata
print(tabella_contingenza)

# Creazione Tabella delle frequenze relative congiunte con marginali di riga e colonna
tabella_frequenze <- prop.table(tabella_contingenza)
riga_marginali <- rowSums(tabella_frequenze)
colonna_marginali <- colSums(tabella_frequenze)
tabella_frequenze_marginali <- cbind(tabella_frequenze, Riga= riga_marginali)
tabella_frequenze_marginali <- rbind(tabella_frequenze_marginali, Colonna=c(colonna_marginali, sum(tabella_frequenze)))

# Visualizzazione della tabella 
round(tabella_frequenze_marginali, 4)

# Esecuzione delle Analisi delle Corrispondenze
ca_fit <- ca(tabella_contingenza)
ca_fit
summary(ca_fit) 


# Mappa profili colonna

library(factoextra)

fviz_ca_biplot(ca_fit, map="rowprincipal",
               repel = TRUE,
               geom.row = c("point", "text"), 
               col.row = "blue",              
               geom.col = c("point", "text"), 
               col.col = "red",               
               title = "Mappa dei Profili Colonna: Classi di Vino e Gruppi Sommelier")


# Mappa profili riga

fviz_ca_biplot(ca_fit, map="colprincipal",
               repel = TRUE,
               geom.row = c("point", "text"), 
               col.row = "blue",              
               geom.col = c("point", "text"), 
               col.col = "red",               
               title = "Mappa dei Profili Riga: Classi di Vino e Gruppi Sommelier")

# Mappa dei contributi relativi dei profili riga 
fviz_ca_row(ca_fit, col.row = "cos2",
            gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
            repel = TRUE,
            title="Mappa dei contributi relativi dei profili riga")

# Mappa simmetrica 

fviz_ca_biplot(ca_fit,
               repel = TRUE,
               geom.row = c("point", "text"), 
               col.row = "blue",              
               geom.col = c("point", "text"), 
               col.col = "red",               
               title = "Mappa Simmetrica delle Corrispondenze: Classi di Vino e Gruppi Sommelier")





