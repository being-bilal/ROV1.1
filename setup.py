from setuptools import setup, Extension
from Cython.Build import cythonize

# Define the Cython extension
extensions = [
    Extension(
        name="Control",  # Module name to be imported later
        sources=["Control.pyx"],  # Source file
        libraries=["pigpio"],  # Ensure pigpio is linked properly
        library_dirs=["/usr/local/lib/libpigpio.so"]
    )
]

# Setup script to build the C extension
setup(
    name="Control_module",
    ext_modules=cythonize(extensions, compiler_directives={"language_level": "3"}),
    zip_safe=False,  # Allows using the compiled module in a zip file
)