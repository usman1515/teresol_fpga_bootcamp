
compile_docs:
	@for file in ./docs/*.typ; do \
		name=$$(basename "$$file" .typ); \
		echo "Compiling $$file -> ./$$name.pdf"; \
		typst compile "$$file" "./$$name.pdf"; \
	done

clean:
	rm -rf *.pdf ./*/*.pdf
	rm -rf ./07-yosys-tutorial/bin ./07-yosys-tutorial/*.ys
