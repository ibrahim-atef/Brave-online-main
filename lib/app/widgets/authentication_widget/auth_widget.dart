import 'package:flutter/material.dart';
import 'package:egyptm/common/common.dart';
import 'package:egyptm/config/colors.dart';
import 'package:egyptm/config/styles.dart';

class AuthWidget{

  

  static Widget accountTypeWidget(String title, String selectedType, String type, Function onTap){
    return Expanded(
      child: GestureDetector(
        onTap: (){
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          
          duration: const Duration(milliseconds: 200),
          width: getSize().width,
          height: 42,
            
          decoration: BoxDecoration(
            color: selectedType == type ? mainColor() : Colors.white,
            borderRadius: borderRadius(radius: 15),
          ),
            
          alignment: Alignment.center,
          child: Text(
            title,
            style: style14Regular().copyWith(color: selectedType == type ? Colors.white : greyB2),
          ),
            
        ),
      )
    );
  }

}
