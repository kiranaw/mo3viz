require(sf)
require(ggplot2)
require(dplyr)
require(mapview)
require(readr)
require(ggspatial)
grid=read_sf("~/MO3/2mapviz/test_grid_40K_2.gpkg")

range(grid$id_maille)
nrow(grid)

# as each cell is a square of 200m, there area is 40000m²
st_area(head(grid))

#here a shape with the estimation of the population :
pop=read_sf("~/MO3/2mapviz/estim_pop_square_meta_200m.gpkg")

# the area is okay
head(st_area(pop))
# same number of cells
nrow(grid)==nrow(pop)
# but i've done this with an old grid that with cell ID that are not correct
range(pop$id_grid)

# So : how to fix this?
# take the centroid of each cell of the "pop" file
pop_centro=st_centroid(pop)
head(pop_centro)
#  intersect that with the grid
grid_inter=pop_centro %>%
  st_intersection(grid)
# we will just keep the statistics 
grid_inter=grid_inter %>% st_drop_geometry() %>%
  dplyr::select(id_maille, # the id of the proper grid
               pop_estim_cor, # the estimation of the population (corrected by district)
               pop_estim) # the raw estimation of the population
# merge with the grid
grid=grid %>% left_join(grid_inter,by="id_maille")

ggplot(grid)+
  geom_sf(aes(fill=pop_estim_cor),col=NA)+
  scale_fill_distiller(palette="Spectral",name="Estimation of\nthe population")+
  annotation_scale(location="br")+
  theme_minimal()


# let's do the same thing with the subdistrict :
dopa=read_sf("~/MO3/2mapviz/dopa_shp_2020.shp")
# the dopa is the office of the thai government that register people in Bangkok.
# here we are just interested by the subdistrict ID
dopa=dopa %>% dplyr::select(SUBDISTRI) %>% # by default the geometry will be also taken
  rename(kw=SUBDISTRI) # I rename the subdistrict 'kw' for khwaeng, the thai name (I forgot the h 8 years ago, so for me it's "kw" not "khw")

# is it the same CRS (coordinate refefence system) ?
st_crs(dopa)==st_crs(grid)

# here we'll convert the grid into point as each cell is supposed to be smaller than a district and the point will be regular
grid_pts=grid %>% st_centroid()
# and we intersect
grid_pts=grid_pts %>% st_intersection(dopa)
# we just keep the informaiton we want : the id_maille & kw
grid_pts = grid_pts %>% st_drop_geometry() %>%
  dplyr::select(id_maille,kw)
# and we merge with the grid
grid=grid %>% left_join(grid_pts,by="id_maille")


grid %>%
  mutate(kw_fact=as.factor(kw)) %>%
  ggplot()+
  geom_sf(aes(fill=kw_fact),col=NA)+
  geom_sf(data=dopa,fill=NA,col="black",lwd=0.1)+
  scale_fill_discrete(guide=FALSE)+ # guide=FALSE to suppress the legend
  annotation_scale(location="br")+
  theme_minimal()

# now we can save it
#write_sf(grid,"~/Documents/MO3/MOMO/grid_40K_pop_180kw.gpkg")


# aggregate by khwaeng :
grid_kw=grid %>% 
  group_by(kw) %>%
  summarise(pop=sum(pop_estim_cor)) %>%
  ungroup()

mapview(grid_kw,zcol="pop")




