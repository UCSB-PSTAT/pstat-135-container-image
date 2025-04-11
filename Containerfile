FROM ucsb/all-spark-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

#Configure R/openjdk for arrow
RUN R CMD javareconf

RUN R -e "install.packages(c('aws.s3', 'bench', 'bookdown', 'ff', 'foreach', 'future', 'gamlr', 'keras', 'scattermore', 'tensorflow', 'tfestimators'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

RUN R -e "devtools::install_github('edwindj/ffbase', subdir='pkg')"

RUN conda install -c conda-forge -y --freeze-installed --no-update-deps \
    r-arrow\
    r-rjdbc

#RUN pip install <packages>

USER $NB_USER

