1. Install the right python version in conda env
2. Install cython: https://anaconda.org/anaconda/cython
3. Change the name of the python script you wanna cythonize / compile inside the `setup.py`
4. Execute the following code in terminal or run the `runme.sh` script:
```bash
python3 setup.py build_ext --inplace
```
