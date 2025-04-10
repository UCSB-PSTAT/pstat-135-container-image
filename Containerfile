FROM ucsb/all-spark-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

#RUN R -e "install.packages(c('<library>', '<library>'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

#RUN mamba install -y <packages>

#RUN pip install <packages>


USER $NB_USER

