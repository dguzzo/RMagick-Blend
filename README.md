# RMagick-Blend

A small gem that uses RMagick—a gem that acts as a wrapper around the classic [ImageMagick](http://www.imagemagick.org/) library—to run various composite operations on source images, producing a composite output.

[Examples here](http://www.flickr.com/photos/dominicotine/collections/72157633447005928/)

## Table of Contents
* [Installation](#installation)
* [Running blending script](#running-blending)
* [List of composite operations](#list-of-composite-operations)
   
## installation
    ### building & installing from source
        git clone https://github.com/dguzzo/RMagick-Blend.git
        gem build rmagick-blend.gemspec
        gem install rmagick-blend[version].gem
        
## running-blending
	    require 'rmagick-blend'

      blender = RMagickBlend::Blend.new
      blender.create_blends
		
## List of composite operations
[link to outputted file](all_ops.txt)

# Feedback
Comments on the sanity of my code—either general or specific—are **extremely** welcomed.
