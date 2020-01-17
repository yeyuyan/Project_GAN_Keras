# -*- coding: utf-8 -*-
"""
Created on Thu May 23 10:11:00 2019

@author: YE677
"""

directory = "C:\\Users\\YE677\\Desktop\\Projet_deep_learning\\Cycles_zip\\Cycles\\"

def show_images():
        r, c = 3,3 

        # Rescale images 0 - 1
                    
        Lon, Lat = [], []
        for i in range (r*c):
            Lon.append(tab[i][1])
            Lat.append(tab[i][0])
                    
        fig, axs = plt.subplots(r, c)
        
        cnt = 0
        for i in range(r):
            for j in range(c):
                axs[i,j].plot(Lon[cnt],Lat[cnt])
                cnt += 1
                
        fig.savefig("images/affichage.png")
        plt.close()
        
        
images=[]
for image in os.listdir(directory):
    if image.endswith(".csv"):
        xd=directory + image
        images.append(xd)
taille=len(images)
def getElem(file, i, j):
    with open(file, 'r') as f:
        reader = csv.reader(f)
        for line in reader:
            if reader.line_num - 1 == i:
                return line[j]
data=[1, 2, 6]
# rescale to -1, 1
scale=[90,135,10]
tab=np.zeros((100,3,100))

Nb = int(input("Nombre de fichier CSV à ouvrir :"))

for k in range(Nb):
        for l in range(0,3):
            for i in range(1,100):
                a=getElem(images[k],i,data[l])
                if a == None or a == '':
                    tab[k][l][i]=tab[k][l][i-1]
                else:
                    tab[k][l][i]=float(a)/scale[l]
            tab[k][l][0]=tab[k][l][1]

show_images()
                
