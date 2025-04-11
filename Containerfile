FROM ucsb/all-spark-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

RUN R -e "install.packages(c('arrow', 'aws.s3', 'bench', 'bookdown', 'ff', 'foreach', 'future', 'keras', 'RJDBC', 'scattermore', 'tensorflow', 'tfestimators'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

RUN R -e "devtools::install_github('edwindj/ffbase')"

#RUN conda install -c conda-forge -y\

#RUN pip install <packages>

USER $NB_USER

