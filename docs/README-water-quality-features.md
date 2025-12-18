# HELOISA - Extreme Events Detection - Muddy Waters/Industrial Waste & Surface Formations
Extreme Events Detection services for Muddy Water, Industrial Waste and Surface Formations mapping.

## Table of contents
<!-- TABLE OF CONTENTS -->
<details>
  <!-- <summary>Table of Contents</summary> -->
  <ol>
    <li><a href="#overview">Overview</a></li>
    <li><a href="#quick-start">Quick Start</a></li>
    <li><a href="#installation--deployment">Installation & Deployment</a></li>
      <ul>
        <li><a href="#requirements--installing-dependencies">Requirements / Installing Dependencies</a></li>
        <li><a href="#input-data-from-s3">Input Data from S3</a></li>
        <li><a href="#deployment-scenarios">Deployment Scenarios</a></li>
        <li><a href="#environment-variables--secrets">Environment Variables & Secrets</a></li>
      </ul>
    <li><a href="#service-execution">Service Execution</a></li>
    <ul>
      <li><a href="#step-by-step-usage">Step-by-Step Usage</a></li>
      <li><a href="#input-data-requirements">Input Data Requirements</a></li>
      <li><a href="#output-products--formats">Output Products & Formats</a></li>
      <li><a href="#error-handling--troubleshooting">Error Handling & Troubleshooting</a></li>
    </ul>
    <li><a href="#components--services">Components / Services</a></li>
    <li><a href="#development--testing">Development & Testing</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#License">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

## Overview
Short description of the repository, goals, intended users, and high-level architecture. Replace placeholders with project-specific details.

## Quick Start
Minimal instructions to get the repository running locally (Docker + CWL example):
1. Build worker image:
   - cd docker
   - docker build -f muddy.dockerfile -t muddy-service:latest ..
   - docker save -o muddy.tar muddy-service:latest
   - mv muddy.tar ../
2. Start ancillary services:
   - docker-compose up -d rabbitmq
   - (optional) docker-compose up -d flower
3. Start Celery worker (optional):
   - cwltool --custom-net=xtreme-net --enable-ext task.cwl
4. Run workflow:
   - cwltool --custom-net=xtreme-net --enable-ext muddy.cwl inputs.yaml

## Installation & Deployment
Installation steps for local development and basic deployment examples.

Local (developer):
- Clone repo
- Install Python 3.11+ and `uv` (or use virtualenv)
- `uv add -r requirements.txt` (or manual installation)
- Build Docker image (see Quick Start)

Docker-compose (simple deployment):
- cd docker
- docker-compose up -d --build
- docker-compose down -v --remove-orphans

Kubernetes (example notes):
- Provide Kubernetes manifests under `deploy/` (Deployment, Service, ConfigMap, Secret)
- Use image registry for muddy-service and set imagePullSecrets as needed
- Example: kubectl apply -f deploy/

CI/CD:
- Add pipeline steps: build image, push image, run unit tests, run lint

## Requirements / Installing Dependencies
[![SNAP][SNAP-badge]][SNAP-url]
[![xarray][xarray-badge]][xarray-url]
[![rasterio][rasterio-badge]][rasterio-url]
[![GDAL][gdal-badge]][gdal-url]
[![dask][dask-badge]][dask-url]
[![pystac][pystac-badge]][pystac-url]
[![rioxarray][rioxarray-badge]][rioxarray-url]
[![shapely][shapely-badge]][shapely-url]
[![scikit-image][scikit-image-badge]][scikit-image-url]
[![pyproj][pyproj-badge]][pyproj-url]
[![pytest][pytest-badge]][pytest-url]
[![NumPy][numpy-badge]][numpy-url]
[![C2RCC][c2rcc-badge]][c2rcc-url]
[![Docker][docker-badge]][docker-url]

- Host System (tested):
  - Ubuntu: 22.04, 24.04
  - Docker: 28.1.1 (build 4eba377), 28.3.2 (build 578ccf6)
  - cwltool: 3.1.20240112164112, 3.1.20220224085855
- Python dependencies managed with `uv`. A detailed version of libraries can be found in `pyproject.toml`
- ESA SNAP: 11.0.0
- GDAL: 3.13.0dev-0e5bb914b80d049198d9a85e04b22c9b0590cc36 (released 2025/11/26)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Input data from S3
- Climatologies per lake for the C2RCC atmospheric correction. Some examples are seen below:
  - `s3://qa-thematic-service-water/water-quality/climatologies/GR0723L000000001N_climatology.csv`
  - `s3://qa-thematic-service-water/water-quality/climatologies/GR1436L000000002H_climatology.csv`
  - ...  

- Digital Elevation Model (DEM) of Greece (this will be deprecated as soon as DEM becomes available in the Catalogue)
  - `s3://qa-thematic-service-water/water-quality/merged_dem.zip`

## Deployment Scenarios
- Semi-standalone: docker-compose + local cwltool + uv-managed virtualenv + Authorized access to STAC Catalogue + static data access
- Production through G-Hub (recommended): Architecture based on EOEPCA+, including Kubernetes cluster with autoscaling workers, managed message broker, object storage (S3), Authorized access to STAC Catalogue, and centralized logging/monitoring, among others.

 <!-- Replace with actual variables -->
## Environment Variables & Secrets
The environment variables are stored securely inside Vault in the AWS. A list is provided below:
- `AWS_ACCESS_KEY_ID`: Dedicated S3 buckets user ID
- `AWS_REGION`
- `AWS_SECRET_ACCESS_KEY`: Dedicated S3 buckets secret
- `CATALOG_CLIENT_ID`: STAC Catalog user ID
- `CATALOG_CLIENT_SECRET`: STAC Catalog password
- `S2_BUCKET_NAME`: Dedicated S3 bucket for user's historical data
- `DB_HOST`: DB IP in K8s
- `DB_NAME`: DB name in K8s
- `DB_PASSWORD`: DB password in K8s
- `DB_PORT`: DB port in K8s
- `DB_USER`: DB superuser name
- `NAMESPACE`: K8S and AWS namespace

## Service Execution

### Step-by-Step Usage
1. Prepare inputs.yaml describing dates, bbox, and input S3 paths.
2. Ensure ancillary services are up (RabbitMQ).
3. Start Celery worker (task.cwl) if required:
   - cwltool --custom-net=xtreme-net --enable-ext task.cwl
4. Launch workflow:
   - cwltool --custom-net=xtreme-net --enable-ext muddy.cwl inputs.yaml
5. Monitor progress in terminal or Flower UI (http://localhost:5554).

Parallel run:
- cwltool --parallel --enable-ext muddy.cwl inputs.yaml 2>&1 | ts '[%Y-%m-%d %H:%M:%S]'

### Input Data Requirements
- Spatial: bounding box in EPSG:4326 or specified CRS.
- Temporal: start and end datetimes (ISO8601).
- Product constraints: required bands, resolution, format (GeoTIFF preferred).
- Sample inputs.yaml fields to document.

### Output Products & Formats
STAC-compliant product which includes:
  - Water quality parameter COGs
  - Scene classification for advanced users COG
  - Quality flags for advanced users COG
  - Scene classficiation and quality flag for simple users COG
- Logs

Include:
- Schema or example of report JSON
- Naming conventions for output files
- Output CRS and compression details

### Error Handling & Troubleshooting
Common failure modes and steps:
- Worker cannot connect to RabbitMQ:
  - Check RABBITMQ_HOST and network (docker network xtreme-net)
  - docker-compose ps; docker logs rabbitmq
- Missing input files:
  - Validate S3 URIs and credentials
  - Run input validator or check S3 bucket manually
- CWL task failures:
  - Re-run with --debug or inspect worker logs
  - Look for stack traces in Celery worker terminal
- Dependency mismatch:
  - Ensure uv.lock and pyproject.toml are in sync (uv sync)
  - Use just commands to recreate environment if needed
- Permissions / secrets:
  - Confirm AWS credentials and permissions for S3 read/write

If persistent errors occur:
- Collect logs from worker and broker
- Reproduce minimal failing case locally
- Open an issue with logs, environment, and steps to reproduce

## Components / Services
- RabbitMQ: message broker
- Flower: monitoring UI
- CWL workflows: muddy.cwl, task.cwl
- Python package: src/muddy_service
- Scripts: scripts/ (upgrade helpers, validators)

## Development & Testing
- Linting/formatting: ruff (configured in .justfiles)
- Tests: pytest
- Pre-commit hooks: configured in .pre-commit-config.yaml
- Run tests:
  - pytest
  - just python test

## Contributing
- Fork, create branch, run linters/tests, open PR.
- Follow commit message and review guidelines.

## License
This repository is  property of CDXi Solutions P.C. and is subject to the Non-Disclosure Agreement (NDA) between the Hellenic Space Centre (HSC) and CDXi Solutions.

## Contact
info@cdxi.gr or  
amoumtzid@cdxi.gr


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
[SNAP-badge]: https://img.shields.io/badge/SNAP-ESA-blue?style=for-the-badge
[SNAP-url]: https://step.esa.int/main/toolboxes/snap/
[xarray-badge]: https://img.shields.io/badge/xarray-1.0+-orange?style=for-the-badge
[xarray-url]: https://xarray.dev/
[rasterio-badge]: https://img.shields.io/badge/rasterio-GDAL-green?style=for-the-badge
[rasterio-url]: https://rasterio.readthedocs.io/
[gdal-badge]: https://img.shields.io/badge/GDAL-GDAL-blue?style=for-the-badge&logo=gdal
[gdal-url]: https://gdal.org/
[dask-badge]: https://img.shields.io/badge/dask-dask-blue?style=for-the-badge&logo=dask
[dask-url]: https://dask.org/
[pystac-badge]: https://img.shields.io/badge/pystac-pystac-2B8CFF?style=for-the-badge
[pystac-url]: https://pystac.readthedocs.io/
[rioxarray-badge]: https://img.shields.io/badge/rioxarray-rioxarray-FF6F00?style=for-the-badge
[rioxarray-url]: https://rioxarray.readthedocs.io/
[shapely-badge]: https://img.shields.io/badge/Shapely-Shapely-2F8CC0?style=for-the-badge
[shapely-url]: https://shapely.readthedocs.io/
[tensorflow-badge]: https://img.shields.io/badge/TensorFlow-TensorFlow-orange?style=for-the-badge&logo=tensorflow
[tensorflow-url]: https://tensorflow.org
[scikit-image-badge]: https://img.shields.io/badge/scikit--image-scikit--image-4B8BBE?style=for-the-badge
[scikit-image-url]: https://scikit-image.org/
[pyproj-badge]: https://img.shields.io/badge/pyproj-pyproj-6DB33F?style=for-the-badge
[pyproj-url]: https://pyproj4.github.io/pyproj/stable/
[pytest-badge]: https://img.shields.io/badge/pytest-pytest-4B8BBE?style=for-the-badge&logo=pytest
[pytest-url]: https://pytest.org/
[numpy-badge]: https://img.shields.io/badge/NumPy-NumPy-013243?style=for-the-badge&logo=numpy
[numpy-url]: https://numpy.org/
[pytorch-badge]: https://img.shields.io/badge/PyTorch-PyTorch-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white
[pytorch-url]: https://pytorch.org/
[c2rcc-badge]: https://img.shields.io/badge/C2RCC-C2RCC-blue?style=for-the-badge
[c2rcc-url]: https://c2rcc.org/
[polymer-badge]: https://img.shields.io/badge/Polymer-Polymer-4CAF50?style=for-the-badge
[polymer-url]: https://hygeos.com/en/polymer/
[docker-badge]: https://img.shields.io/badge/Docker-Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white
[docker-url]: https://www.docker.com/