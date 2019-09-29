nb_classes = 6;

function [list_mat_im] = init_data()
    folder = ['C:\Users\LM\Desktop\L3Info\PjtScilab\birds\egret\*',
             'C:\Users\LM\Desktop\L3Info\PjtScilab\birds\mandarin\*',
             'C:\Users\LM\Desktop\L3Info\PjtScilab\birds\owl\*',
             'C:\Users\LM\Desktop\L3Info\PjtScilab\birds\puffin\*',
             'C:\Users\LM\Desktop\L3Info\PjtScilab\birds\toucan\*',
             'C:\Users\LM\Desktop\L3Info\PjtScilab\birds\wood_duck\*'];
              
    list_mat_im = list();          
    [folder_size_l, folder_size_c] =size(folder);
    count = 0;
    for k=1:folder_size_l
        im_vec = dir(folder(k));
        vec_size =size(im_vec.name,"*");
        vec_size = vec_size-90;
        for i=1:vec_size   
            im = imread(im_vec.name(i));
            [descp, feat] = features_extract(im);
            list_mat_im (i+count) = list(descp, k, feat);
        end
        count = count + vec_size;
    end
endfunction



function[l_mat] = extr_bst_match(im_model, list_mat)
    l_mat = list();
    list_mat_size = size(list_mat);
    [M_descp, M_feat] = features_extract(im_model);
    for i=1:list_mat_size
         m = immatch_BruteForce(M_descp, list_mat(i)(1));
         [feat_out1,feat_out2,mout] = imbestmatches(M_feat, list_mat(i)(3),m,10);
         l_mat(i) = list(mout, list_mat(i)(2));
    end
endfunction


function [class] = cmp_mat(model_image, list_mat)
    list_mat_im = list_mat;
    list_mat_im_size = size(list_mat_im);
    
    [final_list] = bst_match(list_mat, list_mat_im_size);
    im_mod_list = extr_bst_match(model_image, list_mat);
    vect_dist = dist_eucl(im_mod_list, final_list);
 
    minDist = vect_dist(1);
    for i=1:size(vect_dist)
        if(minDist(1) > vect_dist(i)(1))
            minDist = vect_dist(i);
        end
    end
    class = minDist(2);
endfunction


function [descp, feat] = features_extract(image)
     feat = imdetect_SURF(image);
     descp = imextract_DescriptorSURF(image,feat);
endfunction


function [vect_dist] = dist_eucl(im_mod_list, final_list)
    vect_dist = list();
    matModel_vect = list();
    finalList_vect = list();
    count = 1;
    for i=1:size(final_list)
       if(sum(final_list(i)(1)) > 110)
            finalList_vect(count) = list((final_list(i)(1))(:), final_list(i)(2));
            count = count +1;   
       end    
    end
    
    for j=1:size(im_mod_list)
       matModel_vect(j) = (im_mod_list(j)(1))(:); 
    end
 
    indice = 0;
    for i=1:size(finalList_vect)
       for j=1:size(matModel_vect)
           vect_dist(j+indice) = list(norm(finalList_vect(i)(1) - matModel_vect(j)), finalList_vect(i)(2));
       end
       indice = indice + size(matModel_vect);
    end
endfunction


function [bst_matrice] = bst_match(list_desc, list_size)
    bst_matrice = list();
    count = list_size / nb_classes
    index_list = 0;
    index = 0;
    for i=1:nb_classes
        for j=1:count   
            for k=1:count
                m = immatch_BruteForce(list_desc(j+index)(1), list_desc(k+index)(1));
                [feat_out1,feat_out2,mout] = imbestmatches(list_desc(j+index)(3), list_desc(k+index)(3),m,10);
                bst_matrice(k+index_list) = list(mout,i);
            end
            index_list = index_list + count;
        end
        index = index + count;
    end
    
endfunction


function [str] = cluster(image_model)
    classes = list('egret', 'mandarin', 'owl', 'puffin', 'toucan', 'wood_duck');
    list_mat = init_data();
    class = cmp_mat(image_model, list_mat);
    if(class == 0)then
        str = "I couldnt reconize it";
    else
        str = "this type of birds is " + classes(class) + " bird";
    end
endfunction


