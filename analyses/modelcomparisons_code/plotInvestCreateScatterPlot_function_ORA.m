function plotInvestCreateScatterPlot_function_ORA(age, binProportionsPp, pInvestsFromModel, drawScatter, drawLine)
	subjectProps = binProportionsPp;
	modelProps = pInvestsFromModel;
	colors = [0,191,255; 0,0,255;50,205,50; 0,100,0] / 255;
	size = 40;
	if drawScatter
		scatter(modelProps(:), subjectProps(:), [], age(:));%, size, colors(1, :));
	end
	if drawLine
		% dit doet niets tenzij de functie aangeroepen wordt met
		% 'true' als laatste argument
		plot(mean(modelProps), mean(subjectProps), '-', 'Color', colors(1, :), 'LineWidth', 2.5);
	end
end
