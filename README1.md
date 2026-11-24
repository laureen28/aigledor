# Aigle d'Or - lancement sous Linux

Ce document explique comment installer les prérequis, préparer PostgreSQL,
compiler et déployer Aigle d'Or sur Linux, **sans modifier le code Java ou
les JSP**.

Le projet est une application Java EE ancienne, construite avec Apache Ant et
déployée sous forme de WAR explosé dans WildFly 10. Tomcat n'est pas le serveur
prévu par les scripts fournis : WildFly embarque son propre conteneur Web
(Undertow). Il ne faut donc pas lancer Tomcat en parallèle pour ce projet.

---

## 1. Ce que contient le dépôt

| Dossier/fichier | Rôle |
|---|---|
| `socobis-ejb/` | Code Java métier/EJB, propriétés et ressources copiées dans le build. `src/java/` contient notamment `apj.properties`. `nbproject/` contient les fichiers NetBeans et les dépendances historiques. `build/` est un résultat de compilation à ne pas utiliser comme source de configuration. |
| `socobis-war/` | Couche Web. `src/java/` contient les servlets/classes Web, `web/` contient les JSP, JavaScript, CSS, images, bibliothèques front-end et `WEB-INF/`. |
| `build-file/lib/` | Bibliothèques Java utilisées par Ant. Le dossier contient notamment le pilote PostgreSQL, le pilote Oracle historique, les API Java EE, JasperReports et les bibliothèques APJ. |
| `build-aigledor.xml` | Script Ant recommandé. Compile l'EJB et le WAR, copie les ressources et déploie `aigledor.war`. Son `deploy.dir` peut être surchargé en ligne de commande. |
| `build.xml` | Variante de build avec un déploiement relatif (`../deployments`). Ne pas utiliser par défaut si WildFly est installé ailleurs. |
| `build-aigledor-ia.xml` | Variante contenant des chemins Linux et des ressources de prompts IA. Ne pas utiliser pour le lancement Linux standard. |
| `build-jenkins.xml` | Variante destinée à l'intégration continue. |
| `build-hook.xml` / `build-revert-hook.xml` | Installation ou retrait du hook Git. Ils ne sont pas nécessaires pour lancer l'application. |
| `codebar-generator/` | Petit composant Java séparé de génération de codes-barres, avec son propre `apj.properties`. Il n'est pas requis pour le build principal. |
| `bdd/` | Historique de scripts SQL et exports de données. Le sous-dossier `bdd/postgres/` contient les scripts PostgreSQL classés par année/mois. |
| `bdd-async/` | Scripts SQL liés au périmètre asynchrone, également organisés par date et par moteur. |
| `aigledor0110.sql` | Dump PostgreSQL complet fourni à la racine. Il est volumineux et peut servir de base de départ si son contenu correspond à l'environnement souhaité. |
| `control/` | Hook Git `pre-commit`. Il ne participe pas à l'exécution de l'application. |
| `google-adk/` | Composant Python optionnel pour OCR/agent (`main.py`, `asyncAgent/`). Il se lance séparément avec Python et `google-adk` ; il n'est pas appelé par le build Ant Java. |
| `Dockerfile` | Exemple Linux/Alpine avec Java 8 et WildFly 10.1.0. Il peut servir de référence pour une installation conteneurisée. |
| `documentation.txt` | Rappel du déploiement et des configurations attendues. |
| `POS_AIGLEDOR_INFRASTRUCTURE.md` | Documentation fonctionnelle et technique détaillée du POS, de ses JSP, scripts JavaScript et de son routage. |
| `*.iml` | Métadonnées IntelliJ/NetBeans, sans effet sur la commande Ant. |

> **Remarque :** Les dossiers `build/`, `build/classes/`, `build-file/socobis_war/`,
> `build-file/socobis_jar/` et `build-file/ear/` sont des sorties ou des
> répertoires de travail générés par Ant. Le script les recrée pendant le build.

---

## 2. Versions recommandées

Utiliser de préférence les versions suivantes :

- Une distribution Linux 64 bits récente (Debian/Ubuntu, Fedora, RHEL, etc.) ;
- **JDK 8**, pas uniquement un JRE ;
- **Apache Ant 1.9.x ou 1.10.x** compatible avec Java 8 ;
- **WildFly 10.1.0.Final** (le `Dockerfile` du dépôt utilise cette version) ;
- **PostgreSQL 16** si l'on utilise le dump `aigledor0110.sql`. Les scripts
  historiques peuvent cibler une autre version : vérifier leur en-tête avant
  import ;
- un navigateur récent.

> **Important :** Le script historique `build-aigledor.xml` contient encore un
> exemple de chemin vers `wildfly-10.0.0.Final` ; le `Dockerfile` utilise
> `wildfly-10.1.0.Final`. Le chemin local réel sera fourni à Ant par
> `-Ddeploy.dir`, ce qui évite de modifier le XML.

---

## 3. Installer les prérequis

Ouvrir un terminal **en tant qu'utilisateur normal** pour les installations
utilisateur, ou en `root`/`sudo` si l'installation système le demande.

### 3.1 JDK 8

Selon la distribution :

**Debian/Ubuntu** (via `apt`) :

```bash
sudo apt update
sudo apt install -y openjdk-8-jdk
```

**Fedora** (via `dnf`) :

```bash
sudo dnf install -y java-1.8.0-openjdk-devel
```

**RHEL/CentOS** (via `yum`) :

```bash
sudo yum install -y java-1.8.0-openjdk-devel
```

**Arch Linux** (via `pacman`) :

```bash
sudo pacman -S jdk8-openjdk
```

**Alternative portable** (Temurin 8 téléchargé manuellement) :

```bash
mkdir -p ~/tools
cd ~/tools
curl -L -o temurin8.tar.gz \
  "https://github.com/adoptium/temurin8-binaries/releases/latest/download/OpenJDK8U-jdk_x64_linux_hotspot_latest.tar.gz"
tar -xzf temurin8.tar.gz
```

Vérifier ensuite :

```bash
java -version
javac -version
```

La sortie doit indiquer une version `1.8`. Si plusieurs JDK sont installés,
définir `JAVA_HOME` vers le répertoire du JDK 8 et placer `$JAVA_HOME/bin`
avant les autres JDK dans `PATH`.

Avec `update-alternatives` (Debian/Ubuntu) :

```bash
sudo update-alternatives --config java
sudo update-alternatives --config javac
```

Sinon, dans `~/.bashrc` (ou `~/.zshrc`) :

```bash
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"
```

Adapter le chemin exact (`ls /usr/lib/jvm/` pour le vérifier), puis recharger :

```bash
source ~/.bashrc
```

### 3.2 Apache Ant

**Debian/Ubuntu** :

```bash
sudo apt install -y ant
```

**Fedora** :

```bash
sudo dnf install -y ant
```

**Arch Linux** :

```bash
sudo pacman -S apache-ant
```

**Installation manuelle** (recommandée pour maîtriser la version) :

```bash
mkdir -p ~/tools
cd ~/tools
curl -L -o ant.tar.gz https://dlcdn.apache.org//ant/binaries/apache-ant-1.10.15-bin.tar.gz
tar -xzf ant.tar.gz
```

Puis dans `~/.bashrc` :

```bash
export ANT_HOME="$HOME/tools/apache-ant-1.10.15"
export PATH="$ANT_HOME/bin:$PATH"
```

Recharger :

```bash
source ~/.bashrc
```

Vérifier :

```bash
ant -version
```

> **Remarque :** Ant doit utiliser le JDK 8 (`JAVA_HOME`), pas un simple JRE.

### 3.3 WildFly 10

Télécharger `wildfly-10.1.0.Final.zip` depuis
[WildFly downloads](https://www.wildfly.org/downloads/), puis l'extraire, par
exemple, dans `~/serveurs/wildfly-10.1.0.Final` :

```bash
mkdir -p ~/serveurs
cd ~/serveurs
curl -L -o wildfly-10.1.0.Final.zip \
  "https://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.zip"
unzip wildfly-10.1.0.Final.zip
```

Définir `WILDFLY_HOME` dans `~/.bashrc` :

```bash
export WILDFLY_HOME="$HOME/serveurs/wildfly-10.1.0.Final"
export PATH="$WILDFLY_HOME/bin:$PATH"
```

Recharger :

```bash
source ~/.bashrc
```

Le déploiement attendu par le script est :

```text
~/serveurs/wildfly-10.1.0.Final/standalone/deployments
```

### 3.4 PostgreSQL

**Debian/Ubuntu** :

```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib
```

**Fedora** :

```bash
sudo dnf install -y postgresql-server postgresql-contrib
sudo postgresql-setup --initdb
```

**Arch Linux** :

```bash
sudo pacman -S postgresql
sudo -u postgres initdb -D /var/lib/postgres/data
```

Démarrer le service :

```bash
sudo systemctl enable --now postgresql
```

Vérifier ensuite :

```bash
systemctl status postgresql
psql --version
```

> **Remarque :** Si `psql` n'est pas dans `PATH`, utiliser son chemin complet,
> par exemple `/usr/lib/postgresql/16/bin/psql`, ou l'ajouter au `PATH`.

---

## 4. Préparer la base PostgreSQL

### 4.1 Créer une base et un utilisateur de développement

Sur la plupart des distributions, le rôle `postgres` est authentifié via
l'utilisateur système `postgres` (peer authentication). Se connecter ainsi :

```bash
adapter apj.properties : jdbc:postgresql://localhost:5433/aigledor0110
sudo -u postgres psql
```

Dans l'invite SQL. Remplacer le mot de passe par une valeur sûre et ne pas la
committer :

```sql
CREATE USER aigledor_dev WITH PASSWORD 'aigle123';
CREATE DATABASE aigledor0110 OWNER aigledor_dev;
\q
```

Si l'authentification `md5`/`scram-sha-256` est configurée dans
`pg_hba.conf`, on peut aussi utiliser :

```bash
psql -U postgres -h localhost -p 5433
```

### 4.2 Importer le dump

`aigledor0110.sql` est un dump PostgreSQL au format SQL texte, généré avec
PostgreSQL 16. L'importer après création de la base :

```bash
psql -U aigledor_dev -h localhost -p 5433 -d aigledor0110 \
  -f "/home/angolatiana/Documents/progy/aigledor/aigledor0110.sql"
```

Adapter le chemin réel. Pour un import avec demande de mot de passe, ne pas
mettre le mot de passe dans la commande.

> **Attention :** Pour les fichiers historiques, choisir uniquement les scripts
> dont le chemin contient `bdd/postgres/` et appliquer les migrations dans leur
> ordre documentaire ; ne pas exécuter au hasard tous les fichiers de `bdd/` et
> `bdd-async/`, car ce sont des snapshots, correctifs et exports de périodes
> différentes.

### 4.3 Configurer `apj.properties`

Le fichier réellement copié dans le WAR est :

```text
socobis-ejb/src/java/apj.properties
```

Le script Ant le copie pendant la cible `init`. Dans l'état fourni, ce fichier
contient une URL `jdbc:oracle:...` ; il ne correspond donc pas encore à
PostgreSQL, même si le dépôt contient les pilotes PostgreSQL dans
`build-file/lib`.

Faire une copie de sauvegarde locale, puis modifier uniquement les paramètres
de connexion de `socobis-ejb/src/java/apj.properties` (ne pas publier ce
fichier avec un mot de passe réel) :

```properties
apj.connection.url=jdbc:postgresql://localhost:5432/aigledor0110
apj.connection.user=aigledor_dev
apj.connection.password=mot_de_passe_local
apj.connection.driver=org.postgresql.Driver
```

Conserver les autres propriétés déjà présentes, notamment les URL de services.
Si le nom exact de la propriété de mot de passe diffère dans votre copie,
conserver ce nom et remplacer seulement sa valeur.

> **Remarque :** Le build embarque déjà `postgresql-42.2.6.jar` ainsi que
> d'anciens pilotes PostgreSQL dans `build-file/lib` ; aucun téléchargement
> supplémentaire n'est nécessaire pour la compilation.

---

## 5. Démarrer WildFly

Ouvrir une première fenêtre de terminal et la conserver ouverte :

```bash
"$WILDFLY_HOME/bin/standalone.sh" -c standalone.xml
```

Attendre le message de démarrage complet avant de compiler/déployer. Pour
arrêter WildFly, utiliser `Ctrl+C` dans ce terminal. Si le fichier n'est pas
exécutable :

```bash
chmod +x "$WILDFLY_HOME/bin/standalone.sh"
```

- L'interface d'administration est normalement disponible sur
  `http://localhost:9990`.
- Le serveur HTTP de l'application écoute sur `http://localhost:8080`.

---

## 6. Compiler et déployer avec Ant

Ouvrir un **deuxième** terminal à la racine du dépôt :

```bash
cd ~/progy/aigledor
```

Vérifier que les variables et outils sont visibles :

```bash
java -version
ant -version
test -d "$WILDFLY_HOME/standalone/deployments" && echo "OK"
test -d "./build-file/lib" && echo "OK"
```

Lancer le build complet et surcharger le chemin de déploiement sans modifier
`build-aigledor.xml` :

```bash
ant -f ./build-aigledor.xml \
  -Ddeploy.dir="$WILDFLY_HOME/standalone/deployments"
```

La cible par défaut est `deploy`. Elle enchaîne :

1. `clean` : supprime les sorties précédentes ;
2. `init` : recrée les répertoires de build, copie `socobis-war/web`,
   `WEB-INF`, les JAR et `apj.properties` ;
3. `compile` : compile `socobis-ejb/src/java` ;
4. `buildEjbJar` : crée `build-file/ear/socobis-ejb.jar` ;
5. `compileWar` : compile `socobis-war/src/java` dans le WAR ;
6. `copieProperties` : copie les fichiers de traduction ;
7. `deploy` : copie le WAR explosé dans
   `<WILDFLY_HOME>/standalone/deployments/aigledor.war` et crée
   `aigledor.war.dodeploy`.

Un déploiement réussi doit afficher `deployement exploded war done`. Vérifier
ensuite que WildFly a créé ou modifié :

```text
$WILDFLY_HOME/standalone/deployments/aigledor.war.deployed
```

En cas d'échec, consulter :

```text
$WILDFLY_HOME/standalone/log/server.log
```

---

## 7. Ouvrir l'application

Le nom du contexte provient du dossier déployé : `aigledor.war` donne le
contexte `/aigledor`. Le routage applicatif est ensuite assuré par
`pages/module.jsp`. Commencer par :

```text
http://localhost:8080/aigledor/
http://localhost:8080/aigledor/pages/module.jsp
```

Pour le POS, le routage documenté dans
`POS_AIGLEDOR_INFRASTRUCTURE.md` est de la forme :

```text
http://localhost:8080/aigledor/pages/module.jsp?but=vente/vente-saisie-directe-apj.jsp
```

> **Remarque :** Les écrans nécessitant une session, un utilisateur, un point
> de vente ou une caisse doivent être configurés selon les données importées
> dans PostgreSQL.

---

## 8. Relancer proprement après une modification

```bash
cd ~/progy/aigledor
ant -f ./build-aigledor.xml \
  -Ddeploy.dir="$WILDFLY_HOME/standalone/deployments"
```

Pour forcer un redéploiement, arrêter WildFly, supprimer uniquement les sorties
de déploiement de cette application, puis relancer WildFly et Ant :

```bash
rm -rf "$WILDFLY_HOME/standalone/deployments/aigledor.war"
rm -f "$WILDFLY_HOME/standalone/deployments/aigledor.war."*
```

> **Attention :** Ne pas supprimer tout le dossier `deployments` : il peut
> contenir d'autres applications.

---

## 9. Dépannage

### `ant` ou `java` n'est pas reconnu

Recharger le shell (`source ~/.bashrc` ou rouvrir le terminal) après la
modification du `PATH`, vérifier `JAVA_HOME`, puis exécuter `which -a java` et
`which -a ant`. Le premier Java trouvé doit être le JDK 8.

### `deploy.dir` est introuvable

Le chemin est souvent resté celui d'un autre poste ou d'un autre utilisateur.
Utiliser systématiquement
`-Ddeploy.dir="$WILDFLY_HOME/standalone/deployments"` et vérifier avec
`test -d`.

### `standalone.sh` refuse de démarrer (permission refusée)

Rendre le script exécutable :

```bash
chmod +x "$WILDFLY_HOME/bin/standalone.sh"
```

### Le build échoue avec une erreur JDBC

Vérifier que `socobis-ejb/src/java/apj.properties` utilise bien
`jdbc:postgresql://...`, que la base est démarrée
(`systemctl status postgresql`) et que le rôle a les droits. Le fichier est
copié dans `build-file/socobis_jar` pendant `init` ; il faut donc relancer le
build après chaque changement.

### WildFly démarre mais l'application est `failed`

Lire `standalone/log/server.log`, rechercher `ERROR`, `Caused by`,
`ClassNotFoundException` et `SQLException`. Vérifier aussi que le fichier
`.dodeploy` correspond à `aigledor.war` et que le port 8080 n'est pas déjà
occupé (`ss -tlnp | grep 8080` ou `lsof -i :8080`).

### Erreur de version Java ou de compilation

Ce projet utilise des API et une configuration historiques Java EE. Utiliser
Java 8 pour Ant et WildFly, même si un Java plus récent est installé pour
d'autres projets.

### Conflit de port ou de processus

Vérifier ce qui écoute déjà sur les ports 8080 et 9990 :

```bash
ss -tlnp | grep -E ':(8080|9990)'
```

Arrêter le processus concerné ou modifier les ports dans
`$WILDFLY_HOME/standalone/configuration/standalone.xml`.

---

## 10. Composant Python optionnel (`google-adk`)

Ce dossier est indépendant du déploiement Java. Pour l'utiliser, installer
Python 3.9 ou plus récent (par exemple via
`apt install python3 python3-venv` sur Debian/Ubuntu), puis dans
`google-adk` :

```bash
cd ./google-adk
python3 -m venv .venv
./.venv/bin/python -m pip install --upgrade pip
./.venv/bin/python -m pip install google-adk
./.venv/bin/adk api_server
```

> **Remarque :** Ne lancer cette étape que si la fonctionnalité OCR/agent est
> nécessaire.

---

## 11. Résumé de lancement quotidien

```bash
# Terminal 1
"$WILDFLY_HOME/bin/standalone.sh" -c standalone.xml

# Terminal 2, à la racine du dépôt
cd ~/progy/aigledor
ant -f ./build-aigledor.xml \
  -Ddeploy.dir="$WILDFLY_HOME/standalone/deployments"
```

Puis ouvrir :

```text
http://localhost:8080/aigledor/pages/module.jsp
```