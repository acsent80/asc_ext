﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьВидимость(ЭтаФорма);
	
	//Если Объект.Предопределенный Тогда
	//	ТолькоПросмотр = Истина;
	//КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура СводныйУчетПриИзменении(Элемент)
	
	УстановитьВидимость(ЭтаФорма);
	
	Если Объект.СводныйУчет Тогда
		Объект.УчетПоДоговорам        = Ложь;
		Объект.УчетПоНоменклатуре     = Ложь;
		Объект.ПривязыватьКРеализации = Ложь;
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимость(ЭтаФорма)
	
	Объект = ЭтаФорма.Объект;

	ЭтаФорма.Элементы.УчетПоДоговорам.Доступность        = НЕ Объект.СводныйУчет;
	ЭтаФорма.Элементы.УчетПоНоменклатуре.Доступность     = НЕ Объект.СводныйУчет;
	ЭтаФорма.Элементы.ПривязыватьКРеализации.Доступность = НЕ Объект.СводныйУчет;
	
КонецПроцедуры
